//
//  RootViewModelFactory+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.11.2023.
//

import AnywayPaymentBackend
import CalendarUI
import CodableLanding
import CollateralLoanLandingGetShowcaseBackend
import Combine
import Fetcher
import Foundation
import GenericRemoteService
import GetInfoRepeatPaymentService
import LandingMapping
import LandingUIComponent
import ManageSubscriptionsUI
import MarketShowcase
import OperatorsListComponents
import PayHub
import PayHubUI
import PaymentSticker
import RemoteServices
import SberQR
import SerialComponents
import SharedAPIInfra
import SwiftUI
import VortexTools

extension RootViewModelFactory {
    
    func make(
        dismiss: @escaping () -> Void,
        featureFlags: FeatureFlags
    ) -> RootViewDomain.Binder {
        
        // keep for manual override of release flags
        let featureFlags = FeatureFlags(
            c2gFlag: featureFlags.c2gFlag,
            getProductListByTypeV6Flag: .active,
            paymentsTransfersFlag: .active,
            savingsAccountFlag: featureFlags.savingsAccountFlag,
            collateralLoanLandingFlag: featureFlags.collateralLoanLandingFlag,
            splashScreenFlag: featureFlags.splashScreenFlag,
            orderCardFlag: featureFlags.orderCardFlag
        )
        
        let httpClient = infra.httpClient
        let logger = infra.logger
        
        var bindings = Set<AnyCancellable>()
        
        func performOrWaitForActive(
            _ work: @escaping () -> Void
        ) {
            bindings.insert(model.performOrWaitForActive(work))
        }
        
        func performOrWaitForAuthorized(
            _ work: @escaping () -> Void
        ) {
            bindings.insert(model.performOrWaitForAuthorized(work))
        }
        
        func runOnEachNextActiveSession(
            _ work: @escaping () -> Void
        ) {
            bindings.insert(self.runOnEachNextActiveSession(work))
        }
        
        let cachelessHTTPClient = model.cachelessAuthorizedHTTPClient()
        
        model.getProductsV7 = Services.getProductListByTypeV7(cachelessHTTPClient, logger: logger)
        
        model.getBannerCatalogListV2 = Services.getBannerCatalogListV2(httpClient, logger: logger)
        
        let rsaKeyPairStore = makeLoggingStore(
            store: KeyTagKeyChainStore<RSADomain.KeyPair>(keyTag: .rsa)
        )
        
        let resetCVVPINActivation = makeResetCVVPINActivation(
            rsaKeyPairStore: rsaKeyPairStore
        )
        
        let cvvPINServicesClient = Services.cvvPINServicesClient(
            httpClient: httpClient,
            logger: logger,
            rsaKeyPairStore: rsaKeyPairStore
        )
        
        let fastPaymentsFactory = makeFastPaymentsFactory()
        
        let stickerViewFactory: StickerViewFactory = .init(
            model: model,
            httpClient: httpClient,
            logger: logger
        )
        
        let userAccountNavigationStateManager = makeUserAccountNavigationStateManager(
            fastPaymentsFactory: fastPaymentsFactory
        )
        
        let sberQRServices = Services.makeSberQRServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let qrViewModelFactory = makeQRViewModelFactory(
            c2gFlag: featureFlags.c2gFlag,
            paymentsTransfersFlag: featureFlags.paymentsTransfersFlag
        )
        
        let paymentsTransfersFactoryComposer = PaymentsTransfersFactoryComposer(
            model: model
        )
        let makeUtilitiesViewModel = paymentsTransfersFactoryComposer.makeUtilitiesViewModel(
            log: infoNetworkLog
        )
        
        let unblockCardServices = Services.makeUnblockCardServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let blockCardServices = Services.makeBlockCardServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let userVisibilityProductsSettingsServices = Services.makeUserVisibilityProductsSettingsServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let getSVCardLimitsServices = Services.makeGetSVCardLimitsServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let changeSVCardLimitServices = Services.makeChangeSVCardLimitServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let makeSVCardLandig = model.landingSVCardViewModelFactory
        
        let landingService = Services.makeSVCardLandingServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let productProfileServices = ProductProfileServices(
            createBlockCardService: blockCardServices,
            createUnblockCardService: unblockCardServices,
            createUserVisibilityProductsSettingsService: userVisibilityProductsSettingsServices,
            createCreateGetSVCardLimits: getSVCardLimitsServices,
            createChangeSVCardLimit: changeSVCardLimitServices,
            createSVCardLanding: landingService, 
            getSavingsAccountInfo: getSavingsAccountInfo,
            repeatPayment: repeatPayment,
            makeSVCardLandingViewModel: makeSVCardLandig,
            makeInformer: { [weak model] in
                
                model?.action.send(ModelAction.Informer.Show(informer: .init(message: $0, icon: .check)))
            }
        )
        
        let controlPanelModelEffectHandler = ControlPanelModelEffectHandler(
            cancelC2BSub: { (token: SubscriptionViewModel.Token) in
                
                let action = ModelAction.C2B.CancelC2BSub.Request(token: token)
                self.model.action.send(action)
            })
        
        let historyEffectHandlerMicroServices = HistoryEffectHandlerMicroServices(
            makeFilterModel: { payload, completion in
                
                let reducer = FilterModelReducer()
                let composer = FilterEffectHandlerMicroServicesComposer(model: self.model)
                let filterEffectHandler = FilterModelEffectHandler(
                    microServices: composer.compose()
                )
                let firstDay = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                let services = self.model.historyCategories(range: payload.state.selectDates ?? firstDay...Date(), productId: payload.productId)
                let viewModel = FilterViewModel(
                    initialState: .init(
                        productId: payload.productId,
                        calendar: .init(
                            date: Date(),
                            range: .init(range: payload.state.selectDates ?? firstDay...Date()),
                            monthsData: .generate(startDate: self.model.calendarDayStart(payload.productId)),
                            periods: FilterHistoryState.Period.allCases
                        ),
                        filter: .init(
                            title: "Фильтры",
                            selectDates: payload.state.selectDates ?? firstDay...Date(),
                            selectedPeriod: .dates,
                            selectedTransaction: payload.state.selectedTransaction,
                            selectedServices: payload.state.selectedServices,
                            periods: FilterHistoryState.Period.allCases,
                            transactionType: FilterHistoryState.TransactionType.allCases,
                            services: services
                        ),
                        status: services.isEmpty ? .empty : .normal
                    ),
                    reduce: reducer.reduce,
                    handleEffect: filterEffectHandler.handleEffect
                )
                completion(viewModel)
            }
        )
        
        let historyEffectHandler = HistoryEffectHandler(
            microServices: historyEffectHandlerMicroServices
        )
        
        let productNavigationStateManager = ProductProfileFlowManager(
            reduce: makeProductProfileFlowReducer().reduce(_:_:),
            handleEffect: ProductNavigationStateEffectHandler(
                handleHistoryEffect: historyEffectHandler.handleEffect
            ).handleEffect,
            handleModelEffect: controlPanelModelEffectHandler.handleEffect
        )
        
        let makeCardGuardianPanel: ProductProfileViewModelFactory.MakeCardGuardianPanel = {
            return .fullScreen(.cardGuardian($0))
        }
        
        let servicePaymentBinderComposer = ServicePaymentBinderComposer(
            fraudDelay: settings.fraudDelay,
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: schedulers.main
        )
        let makeServicePaymentBinder = servicePaymentBinderComposer.makeBinder
        
        let servicePickerFlowModelFactory = PaymentProviderServicePickerFlowModelFactory(
            makeServicePaymentBinder: { makeServicePaymentBinder($0, .none) }
        )
        
        let transactionComposer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let utilityNanoServicesComposer = UtilityPaymentNanoServicesComposer(
            model: model,
            httpClient: httpClient,
            log: logger.log,
            loadOperators: { $1([]) } // not used for servicePickerComposer
        )
        let asyncPickerComposer = AsyncPickerEffectHandlerMicroServicesComposer(
            composer: transactionComposer,
            model: model,
            makeNanoServices: utilityNanoServicesComposer.compose
        )
        let servicePickerComposer = PaymentProviderServicePickerFlowModelComposer(
            factory: servicePickerFlowModelFactory,
            makeMicroServices: asyncPickerComposer.compose,
            model: model,
            scheduler: schedulers.main
        )
        
        let makePaymentProviderServicePickerFlowModel = makeProviderServicePickerFlowModel()
        
        let getLanding = nanoServiceComposer.compose(
            createRequest: RequestFactory.createMarketplaceLandingRequest,
            mapResponse: LandingMapper.map
        )
        
        let makeOrderCardViewModel = {
            //TODO: implement makeOrderCardViewModel composer
        }
        
        let (paymentsTransfersPersonal, loadCategoriesAndNotifyPicker) = makePaymentsTransfersPersonal(c2gFlag: featureFlags.c2gFlag)
        
        let loadBannersList = makeLoadBanners()
        
        let paymentsTransfersCorporate = makePaymentsTransfersCorporate(
            featureFlags: featureFlags,
            bannerPickerPlaceholderCount: 6,
            nanoServices: .init(loadBanners: loadBannersList)
        )
        
        let hasCorporateCardsOnlyPublisher = model.products.map(\.hasCorporateCardsOnly).eraseToAnyPublisher()
        
        let paymentsTransfersSwitcher = PaymentsTransfersSwitcher(
            hasCorporateCardsOnly: hasCorporateCardsOnlyPublisher,
            corporate: paymentsTransfersCorporate,
            personal: paymentsTransfersPersonal,
            scheduler: schedulers.main
        )
        
        runOnEachNextActiveSession(loadCategoriesAndNotifyPicker)
        
        if featureFlags.paymentsTransfersFlag.isActive {
            
            performOrWaitForActive(loadCategoriesAndNotifyPicker)
        }
        
        let makeProductProfileViewModel = ProductProfileViewModel.make(
            with: model,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makeTemplates: makeMakeTemplates(featureFlags.paymentsTransfersFlag),
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            landingServices: .init(loadLandingByType: { getLanding(( "", $0), $1) }),
            productProfileServices: productProfileServices,
            qrViewModelFactory: qrViewModelFactory,
            cvvPINServicesClient: cvvPINServicesClient,
            productNavigationStateManager: productNavigationStateManager,
            makeCardGuardianPanel: makeCardGuardianPanel,
            makeRepeatPaymentNavigation: getInfoRepeatPaymentNavigation(from:activeProductID:getProduct:closeAction:),
            makeSubscriptionsViewModel: makeSubscriptionsViewModel,
            updateInfoStatusFlag: updateInfoStatusFlag,
            makePaymentProviderPickerFlowModel: makeSegmentedPaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder,
            makeOpenNewProductButtons: { _ in [] },
            operationDetailFactory: makeOperationDetailFactory(),
            makeOrderCardViewModel: makeOrderCardViewModel,
            makePaymentsTransfers: { paymentsTransfersSwitcher }
        )
        
        let makeProductProfileByID: (ProductData.ID, @escaping () -> Void) -> ProductProfileViewModel? = { [weak self] id, dismiss in
            
            guard let self,
                  let product = model.product(productId: id)
            else { return nil }
            
            return makeProductProfileViewModel(
                product,
                "",
                .defaultFilterComponents(product: product),
                dismiss
            )
        }
        
        performOrWaitForActive { [weak self] in
            
            guard let self else { return }
            
            let serial = model.localAgent.serial(for: [OperatorsListComponents.SberOperator].self)
            model.handleDictionaryAnywayOperatorsRequest(serial)
        }
        
        let mainViewBannersBinder = makeBannersForMainView(
            bannerPickerPlaceholderCount: 6,
            nanoServices: .init(
                loadBanners: loadBannersList,
                // TODO: add real serial model.localAgent.serial(for: LandingType.self)
                loadLandingByType: { getLanding(( "", $0), $1) }
            )
        )
        
        // call and notify bannerPicker
        performOrWaitForActive {
            
            loadBannersList {
                
                guard let paymentsTransfersBannerPicker = paymentsTransfersCorporate.content.bannerPicker.bannerBinder
                else { return }
                
                paymentsTransfersBannerPicker.content.event(.loaded($0))
                mainViewBannersBinder.content.bannerPicker.content.event(.loaded($0))
            }
        }
        
        let getLandingByType = nanoServiceComposer.compose(
            createRequest: RequestFactory.createMarketplaceLandingRequest,
            mapResponse: LandingMapper.map,
            mapError: MarketShowcaseDomain.ContentError.init(error:)
        )
        
        let marketShowcaseComposer = MarketShowcaseComposer(
            nanoServices: .init(
                loadLanding: { getLandingByType(( "", $0), $1) },
                orderCard: {_ in },
                orderSticker: {_ in }),
            scheduler: schedulers.main
        )
        let marketShowcaseBinder = marketShowcaseComposer.compose()
        
        let savingsAccount = makeSavingsAccount()
        
        // MARK: - Splash
        
        let splash = makeSplashScreenViewModel(
            initialState: .initialSplashData,
            phaseOneDuration: settings.splash.phaseOneDuration,
            phaseTwoDuration: settings.splash.phaseTwoDuration
        )
        
        model.auth
            .sink { auth in
                
                if auth == .authorized, featureFlags.splashScreenFlag == .active {
                    
                    splash.event(.start)
                }
            }
            .store(in: &bindings)

        // MARK: - Notifications Authorized
        
        performOrWaitForAuthorized { [weak self] in
            
            self?.updateAuthorizedClientInform()
        }
        
        updateClientInformAlerts()
            .store(in: &bindings)
        
        let bannersBox = makeBannersBox(flags: featureFlags)
        
        if featureFlags.needGetBannersMyProductListV2 {
            
            performOrWaitForAuthorized { [weak bannersBox] in
                
                bannersBox?.requestUpdate()
            }
        }
        
        let rootViewModel = make(
            featureFlags: featureFlags, 
            bannersBox: bannersBox,
            splash: splash,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeTemplates: makeMakeTemplates(featureFlags.paymentsTransfersFlag),
            fastPaymentsFactory: fastPaymentsFactory,
            stickerViewFactory: stickerViewFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            productNavigationStateManager: productNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            landingServices: .init(loadLandingByType: { getLanding(( "", $0), $1) }),
            updateInfoStatusFlag: updateInfoStatusFlag,
            onRegister: resetCVVPINActivation,
            makePaymentProviderPickerFlowModel: makeSegmentedPaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder,
            paymentsTransfersSwitcher: paymentsTransfersSwitcher,
            bannersBinder: mainViewBannersBinder,
            makeOpenNewProductButtons: { [weak self] in
                
                guard let self else { return [] }
                return makeOpenNewProductButtons(
                    collateralLoanLandingFlag: featureFlags.collateralLoanLandingFlag,
                    savingsAccountFlag: featureFlags.savingsAccountFlag,
                    action: $0
                )
            },
            marketShowcaseBinder: marketShowcaseBinder,
            makePaymentsTransfers: { paymentsTransfersSwitcher }
        )
        
        let marketBinder = MarketShowcaseToRootViewModelBinder(
            marketShowcase: rootViewModel.tabsViewModel.marketShowcaseBinder,
            rootViewModel: rootViewModel,
            scheduler: schedulers.main
        )
        
        bindings.formUnion(marketBinder.bind())
        
        let witness = RootViewDomain.ContentWitnesses(
            isFlagActive: featureFlags.paymentsTransfersFlag == .active
        )
        
        let getRootNavigation = { select, notify, completion in
            
            self.getRootNavigation(
                c2gFlag: featureFlags.c2gFlag, 
                makeProductProfileByID: makeProductProfileByID,
                select: select,
                notify: notify,
                completion: completion
            )
        }
        
        typealias GN = FlowDomain<RootViewSelect, RootViewNavigation>.GetNavigation
        let decorateGetRootNavigation: (@escaping GN) -> GN  = schedulers.interactive.decorateGetNavigation(
            delayProvider: {
              
                // TODO: - extract to helper func
                switch $0 {
                case .failure, .outside:
                    return .zero
                
                case .orderCardResponse:
                    return .milliseconds(100)

                case .scanQR, .templates:
                    return .zero//.milliseconds(100)
                
                case .openProduct, .searchByUIN, .standardPayment, .userAccount:
                    return .milliseconds(600)
                    
                case .savingsAccount:
                    return .milliseconds(100)
                }
            }
        )
        
        let composer = RootViewDomain.BinderComposer(
            bindings: bindings,
            dismiss: dismiss,
            getNavigation: decorateGetRootNavigation(getRootNavigation),
            bindOutside: { $1.bindOutside(to: $0) },
            scheduler: schedulers.main,
            witnesses: .init(content: witness, dismiss: .default)
        )
        
        return composer.compose(with: rootViewModel)
    }
}

extension FeatureFlags {
    
    var needGetBannersMyProductListV2: Bool {
        
        return savingsAccountFlag.isActive ||
        collateralLoanLandingFlag.isActive ||
        orderCardFlag.isActive
    }
}

extension SavingsAccountDomain.ContentState {
    
    var select: SavingsAccountDomain.Select? {
        
        switch status {
        case .initiate, .inflight, .loaded:
            return nil
            
        case let .failure(failure, _):
            switch failure{
            case let .alert(message):
                return .failure(.error(message))
                
            case let .informer(info):
                return .failure(.timeout(info))
            }
        }
    }
}

private extension RootViewDomain.Flow {
    
    func bindOutside(
        to content: RootViewDomain.Content
    ) -> Set<AnyCancellable> {
        
        let outside = $state.compactMap(\.outside)
            .sink { [weak content, weak self] in
                
                guard let content, let self else { return }
                
                switch $0 {
                case .productProfile:
                    break
                    
                case let .tab(tab):
                    content.rootActions.dismissAll()
                    event(.dismiss)
                    
                    switch tab {
                    case .chat:     content.selected = .chat
                    case .main:     content.selected = .main
                    case .payments: content.selected = .payments
                    }
                }
            }
        
        return [outside]
    }
}

private extension FlowState<RootViewNavigation> {
    
    var outside: RootViewDomain.Navigation.RootViewOutside? {
        
        guard case let .outside(outside) = navigation else { return nil }
        
        return outside
    }
}

private extension RootViewDomain.Witnesses.DismissWitnesses<RootViewModel> {
    
    static var `default`: Self {
        
        return .init(
            dismissAll: {
                
                $0.action
                    .compactMap { $0 as? RootViewModelAction.DismissAll }
                    .eraseToAnyPublisher()
            },
            reset: { content in
                
                return {
                    
                    content.resetLink()
                    content.reset()
                }
            }
        )
    }
}

typealias MakeUtilitiesViewModel = PaymentsTransfersFactory.MakeUtilitiesViewModel

extension ProductProfileViewModel {
    
    typealias LatestPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentProvider
    
    typealias UtilityPaymentViewModel = AnywayTransactionViewModel
    typealias MakePTFlowManger = (RootViewModel.RootActions.Spinner?) -> PaymentsTransfersFlowManager
    
    typealias MakeProductProfileViewModel = (ProductData, String, FilterState, @escaping () -> Void) -> ProductProfileViewModel?
    typealias MakeOrderCardViewModel = () -> Void
    
    static func make(
        with model: Model,
        fastPaymentsFactory: FastPaymentsFactory,
        makeUtilitiesViewModel: @escaping MakeUtilitiesViewModel,
        makeTemplates: @escaping PaymentsTransfersFactory.MakeTemplates,
        makePaymentsTransfersFlowManager: @escaping MakePTFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
        landingServices: LandingServices,
        productProfileServices: ProductProfileServices,
        qrViewModelFactory: QRViewModelFactory,
        cvvPINServicesClient: CVVPINServicesClient,
        productNavigationStateManager: ProductProfileFlowManager,
        makeCardGuardianPanel: @escaping ProductProfileViewModelFactory.MakeCardGuardianPanel,
        makeRepeatPaymentNavigation: @escaping MakeRepeatPaymentNavigation,
        makeSubscriptionsViewModel: @escaping UserAccountNavigationStateManager.MakeSubscriptionsViewModel,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        makePaymentProviderPickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderPickerFlowModel,
        makePaymentProviderServicePickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderServicePickerFlowModel,
        makeServicePaymentBinder: @escaping PaymentsTransfersFactory.MakeServicePaymentBinder,
        makeOpenNewProductButtons: @escaping OpenNewProductsViewModel.MakeNewProductButtons,
        operationDetailFactory: OperationDetailFactory,
        makeOrderCardViewModel: @escaping MakeOrderCardViewModel,
        makePaymentsTransfers: @escaping PaymentsTransfersFactory.MakePaymentsTransfers
    ) -> MakeProductProfileViewModel {
        
        return { product, rootView, filterState, dismissAction in
            
            let makeProductProfileViewModel = ProductProfileViewModel.make(
                with: model,
                fastPaymentsFactory: fastPaymentsFactory,
                makeUtilitiesViewModel: makeUtilitiesViewModel,
                makeTemplates: makeTemplates,
                makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
                userAccountNavigationStateManager: userAccountNavigationStateManager,
                sberQRServices: sberQRServices,
                landingServices: landingServices,
                productProfileServices: productProfileServices,
                qrViewModelFactory: qrViewModelFactory,
                cvvPINServicesClient: cvvPINServicesClient,
                productNavigationStateManager: productNavigationStateManager,
                makeCardGuardianPanel: makeCardGuardianPanel,
                makeRepeatPaymentNavigation: makeRepeatPaymentNavigation,
                makeSubscriptionsViewModel: makeSubscriptionsViewModel,
                updateInfoStatusFlag: updateInfoStatusFlag,
                makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
                makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
                makeServicePaymentBinder: makeServicePaymentBinder,
                makeOpenNewProductButtons: makeOpenNewProductButtons,
                operationDetailFactory: operationDetailFactory,
                makeOrderCardViewModel: makeOrderCardViewModel,
                makePaymentsTransfers: makePaymentsTransfers
            )
            
            let makeAlertViewModels = PaymentsTransfersFactory.MakeAlertViewModels(
                dataUpdateFailure: {
                    
                    updateInfoStatusFlag.isActive ? .dataUpdateFailure(primaryAction: $0) : nil
                },
                disableForCorporateCard: {
                    .disableForCorporateCard(primaryAction: $0)
                })
            
            let paymentsTransfersFactory = PaymentsTransfersFactory(
                makeAlertViewModels: makeAlertViewModels,
                makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
                makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
                makeProductProfileViewModel: makeProductProfileViewModel,
                makeSections: { model.makeSections(flag: updateInfoStatusFlag) },
                makeServicePaymentBinder: makeServicePaymentBinder,
                makeTemplates: makeTemplates,
                makeUtilitiesViewModel: makeUtilitiesViewModel,
                makePaymentsTransfers: makePaymentsTransfers
            )
            
            let makeProductProfileViewModelFactory: ProductProfileViewModelFactory = .init(
                makeInfoProductViewModel: {
                    
                    return .init(
                        model: $0.model,
                        product: $0.productData,
                        info: $0.info,
                        showCvv: $0.showCVV,
                        event: $0.events,
                        makeIconView: $0.model.imageCache().makeIconView(for:)
                    )
                },
                makeAlert: {
                    return .init(
                        title: $0.title,
                        message: $0.message,
                        primary: $0.primaryButton,
                        secondary: $0.secondaryButton)
                },
                makeInformerDataUpdateFailure: {
                    updateInfoStatusFlag.isActive ? .updateFailureInfo : nil
                },
                makeCardGuardianPanel: makeCardGuardianPanel,
                makeRepeatPaymentNavigation: makeRepeatPaymentNavigation,
                makeSubscriptionsViewModel: makeSubscriptionsViewModel,
                makeOrderCardViewModel: makeOrderCardViewModel,
                model: model
            )
            
            return .init(
                model,
                fastPaymentsFactory: fastPaymentsFactory,
                makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
                userAccountNavigationStateManager: userAccountNavigationStateManager,
                sberQRServices: sberQRServices,
                productProfileServices: productProfileServices,
                qrViewModelFactory: qrViewModelFactory,
                paymentsTransfersFactory: paymentsTransfersFactory,
                operationDetailFactory: operationDetailFactory,
                cvvPINServicesClient: cvvPINServicesClient,
                product: product,
                productNavigationStateManager: productNavigationStateManager,
                productProfileViewModelFactory: makeProductProfileViewModelFactory,
                filterHistoryRequest: { lowerDate, upperDate, operationType, category in
                    
                    model.action.send(ModelAction.Statement.List.Request(
                        productId: product.id,
                        direction: .custom(start: lowerDate, end: upperDate),
                        operationType: .init(rawValue: operationType ?? .avtodorGroupTitle),
                        category: category
                    ))
                },
                filterState: filterState,
                rootView: rootView,
                dismissAction: dismissAction,
                makeOpenNewProductButtons: makeOpenNewProductButtons
            )
        }
    }
}

// TODO: needs better naming

private extension RootViewModelFactory {
    
    func makeLoggingStore<Key>(
        store: any Store<Key>
    ) -> any Store<Key> {
        
        return LoggingStoreDecorator(
            decoratee: store,
            log: { [weak self] in self?.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        )
    }
    
    typealias ResetCVVPINActivation = () -> Void
    
    func makeResetCVVPINActivation(
        rsaKeyPairStore: any Store<RSADomain.KeyPair>
    ) -> ResetCVVPINActivation {
        
        return rsaKeyPairStore.deleteCacheIgnoringResult
    }
    
    typealias MakeProductProfileViewModel = (ProductData, String, FilterState, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnRegister = () -> Void
    typealias MakePTFlowManger = (RootViewModel.RootActions.Spinner?) -> PaymentsTransfersFlowManager
    
    func make(
        featureFlags: FeatureFlags,
        bannersBox: any BannersBoxInterface<BannerList>,
        splash: SplashScreenViewModel,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        makeTemplates: @escaping PaymentsTransfersFactory.MakeTemplates,
        fastPaymentsFactory: FastPaymentsFactory,
        stickerViewFactory: StickerViewFactory,
        makeUtilitiesViewModel: @escaping MakeUtilitiesViewModel,
        makePaymentsTransfersFlowManager: @escaping MakePTFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        productNavigationStateManager: ProductProfileFlowManager,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        landingServices: LandingServices,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        onRegister: @escaping OnRegister,
        makePaymentProviderPickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderPickerFlowModel,
        makePaymentProviderServicePickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderServicePickerFlowModel,
        makeServicePaymentBinder: @escaping PaymentsTransfersFactory.MakeServicePaymentBinder,
        paymentsTransfersSwitcher: PaymentsTransfersSwitcher,
        bannersBinder: BannersBinder,
        makeOpenNewProductButtons: @escaping OpenNewProductsViewModel.MakeNewProductButtons,
        marketShowcaseBinder: MarketShowcaseDomain.Binder,
        makePaymentsTransfers: @escaping PaymentsTransfersFactory.MakePaymentsTransfers
    ) -> RootViewModel {
        
        let makeAlertViewModels: PaymentsTransfersFactory.MakeAlertViewModels = .init(
            dataUpdateFailure: {
                updateInfoStatusFlag.isActive ? .dataUpdateFailure(primaryAction: $0) : nil
            },
            disableForCorporateCard: {
                .disableForCorporateCard(primaryAction: $0)
            })
        
        let paymentsTransfersFactory = PaymentsTransfersFactory(
            makeAlertViewModels: makeAlertViewModels,
            makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeSections: { self.model.makeSections(flag: updateInfoStatusFlag) },
            makeServicePaymentBinder: makeServicePaymentBinder,
            makeTemplates: makeTemplates,
            makeUtilitiesViewModel: makeUtilitiesViewModel, 
            makePaymentsTransfers: makePaymentsTransfers
        )
                
        let sections = makeMainViewModelSections(
            bannersBinder: bannersBinder,
            c2gFlag: featureFlags.c2gFlag,
            collateralLoanLandingFlag: featureFlags.collateralLoanLandingFlag,
            savingsAccountFlag: featureFlags.savingsAccountFlag
        )
                
        let makeAuthFactory: MakeModelAuthLoginViewModelFactory = { .init(model: $0, rootActions: $1)
        }
        
        let mainViewModelsFactory: MainViewModelsFactory = .init(
            makeAuthFactory: makeAuthFactory,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makePromoProductViewModel: { [weak self] in
                self?.makePromoViewModel(
                    viewModel: $0,
                    actions: $1,
                    featureFlags: featureFlags
                )
            },
            qrViewModelFactory: qrViewModelFactory,
            makeTrailingToolbarItems: makeTrailingToolbarItems(
                featureFlags.c2gFlag
            )
        )
                  
        let mainViewModel = MainViewModel(
            model, 
            bannersBox: bannersBox,
            navigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            landingServices: landingServices,
            paymentsTransfersFactory: paymentsTransfersFactory,
            updateInfoStatusFlag: updateInfoStatusFlag,
            onRegister: onRegister,
            sections: sections,
            bindersFactory: .init(
                bannersBinder: bannersBinder,
                makeCollateralLoanShowcaseBinder: makeCollateralLoanLandingShowcaseBinder,
                makeCollateralLoanLandingBinder: makeCollateralLoanLandingBinder,
                makeCreateDraftCollateralLoanApplicationBinder: makeCreateDraftCollateralLoanApplicationBinder
            ),
            viewModelsFactory: mainViewModelsFactory,
            makeOpenNewProductButtons: makeOpenNewProductButtons,
            getPDFDocument: getPDFDocument,
            scheduler: schedulers.main
        )
        
        let paymentsTransfersViewModel = PaymentsTransfersViewModel(
            model: model,
            makeFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            paymentsTransfersFactory: paymentsTransfersFactory,
            scheduler: schedulers.main
        )
        
        let paymentsModel: RootViewModel.PaymentsModel = {
            
            switch featureFlags.paymentsTransfersFlag.rawValue {
            case .active:
                return .v1(paymentsTransfersSwitcher)
                
            case .inactive:
                return .legacy(paymentsTransfersViewModel)
            }
        }()
        
        let chatViewModel = ChatViewModel()
        
        let informerViewModel = InformerView.ViewModel(model)
        
        let showLoginAction = {
            
            let loginViewModel = ComposedLoginViewModel(
                authLoginViewModel: .init(
                    self.model,
                    shouldUpdateVersion: shouldUpdateVersion,
                    rootActions: $0,
                    onRegister: onRegister
                )
            )
            
            return RootViewModelAction.Cover.ShowLogin(viewModel: loginViewModel)
        }
        
        func shouldUpdateVersion(updateAlert: ClientInformAlerts.UpdateAlert) ->  Bool {
            
            guard let version: String = updateAlert.version else { return false }
            
            return version.compareVersion(to: Bundle.main.appVersionShort) == .orderedDescending
        }
        
        let tabsViewModel = TabsViewModel(
            mainViewModel: mainViewModel,
            paymentsModel: paymentsModel,
            chatViewModel: chatViewModel,
            marketShowcaseBinder: marketShowcaseBinder
        )

        return .init(
            fastPaymentsFactory: fastPaymentsFactory,
            stickerViewFactory: stickerViewFactory,
            navigationStateManager: userAccountNavigationStateManager,
            productNavigationStateManager: productNavigationStateManager,
            tabsViewModel: tabsViewModel,
            informerViewModel: informerViewModel,
            splash: splash,
            model,
            showLoginAction: showLoginAction,
            landingServices: landingServices,
            mainScheduler: schedulers.main
        )
    }
}

// MARK: - Adapters

private extension MarketShowcaseDomain.ContentError {
    
    typealias RemoteError = RemoteServiceError<Error, Error, LandingMapper.MapperError>
    
    init(
        error: RemoteError
    ) {
        switch error {
        case let .performRequest(error):
            if error.isNotConnectedToInternetOrTimeout() {
                self = .init(kind: .informer(.init(message: "Проверьте подключение к сети", icon: .wifiOff)))
            } else {
                self = .init(kind: .alert("Попробуйте позже."))
            }
            
        default:
            self = .init(kind: .alert("Попробуйте позже."))
        }
    }
}

extension Error {
    
    func isNotConnectedToInternetOrTimeout() -> Bool {
        
        guard let sessionError = self as? URLSessionHTTPClient.Error else { return false }
        
        switch sessionError {
        case let .sessionError(error):
            let nsError = error as NSError
            return nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorTimedOut
            
        default: return false
        }
    }
}
