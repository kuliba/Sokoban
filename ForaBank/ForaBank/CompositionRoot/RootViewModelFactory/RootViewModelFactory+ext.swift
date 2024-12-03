//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import AnywayPaymentBackend
import CalendarUI
import CodableLanding
import CollateralLoanLandingGetShowcaseBackend
import Combine
import Fetcher
import ForaTools
import Foundation
import GenericRemoteService
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

extension RootViewModelFactory {
    
    func make(
        dismiss: @escaping () -> Void,
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        paymentsTransfersFlag: PaymentsTransfersFlag,
        savingsAccountFlag: SavingsAccountFlag
    ) -> RootViewDomain.Binder {
        
        var bindings = Set<AnyCancellable>()
        
        func performOrWaitForActive(
            _ work: @escaping () -> Void
        ) {
            bindings.insert(model.performOrWaitForActive(work))
        }
        
        let cachelessHTTPClient = model.cachelessAuthorizedHTTPClient()
        
        if getProductListByTypeV6Flag.isActive {
            model.getProductsV6 = Services.getProductListByTypeV6(cachelessHTTPClient, logger: logger)
        } else {
            model.getProducts = Services.getProductListByType(cachelessHTTPClient, logger: logger)
        }
        
        model.getBannerCatalogListV2 = Services.getBannerCatalogListV2(httpClient, logger: logger)
        
        if collateralLoanLandingFlag.isActive {
            model.featureFlags.productsOpenLoanURL = nil
        }
        
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
            paymentsTransfersFlag: paymentsTransfersFlag
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
        
        let infoPaymentService = Services.makeInfoRepeatPaymentServices(
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
            repeatPayment: infoPaymentService,
            makeSVCardLandingViewModel: makeSVCardLandig,
            makeInformer: {
                self.model.action.send(ModelAction.Informer.Show(informer: .init(message: $0, icon: .check)))
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
        
        let ptfmComposer = PaymentsTransfersFlowManagerComposer(
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: schedulers.main
        )
        
        let makePaymentsTransfersFlowManager = ptfmComposer.compose
        
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
            loadOperators: { $0([]) } // not used for servicePickerComposer
        )
        let utilityNanoServices = utilityNanoServicesComposer.compose()
        let asyncPickerComposer = AsyncPickerEffectHandlerMicroServicesComposer(
            composer: transactionComposer,
            model: model,
            nanoServices: utilityNanoServices
        )
        let servicePickerComposer = PaymentProviderServicePickerFlowModelComposer(
            factory: servicePickerFlowModelFactory,
            microServices: asyncPickerComposer.compose(),
            model: model,
            scheduler: schedulers.main
        )
        
        let makePaymentProviderServicePickerFlowModel = makeProviderServicePickerFlowModel()
        
        let getLanding = nanoServiceComposer.compose(
            createRequest: RequestFactory.createMarketplaceLandingRequest,
            mapResponse: LandingMapper.map
        )
        
        let makeProductProfileViewModel = ProductProfileViewModel.make(
            with: model,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makeTemplates: makeMakeTemplates(paymentsTransfersFlag),
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            landingServices: .init(loadLandingByType: { getLanding(( "", $0), $1) }),
            productProfileServices: productProfileServices,
            qrViewModelFactory: qrViewModelFactory,
            cvvPINServicesClient: cvvPINServicesClient,
            productNavigationStateManager: productNavigationStateManager,
            makeCardGuardianPanel: makeCardGuardianPanel,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel,
            updateInfoStatusFlag: updateInfoStatusFlag,
            makePaymentProviderPickerFlowModel: makeSegmentedPaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder
        )
        
        let collateralLoanLandingShowCase = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetShowcaseRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateGetShowcaseResponse
        )
        
        let paymentsTransfersPersonalNanoServices = composePaymentsTransfersPersonalNanoServices()
        
        let paymentsTransfersPersonal = makePaymentsTransfersPersonal(
            nanoServices: paymentsTransfersPersonalNanoServices
        )
        
        if paymentsTransfersFlag.isActive {
            
            performOrWaitForActive {
                
                paymentsTransfersPersonalNanoServices.reloadCategories { [weak paymentsTransfersPersonal] categories in
                    
                    // notify categoryPicker
                    let categoryPicker = paymentsTransfersPersonal?.content.categoryPicker.sectionBinder
                    
                    guard let categoryPicker else {
                        
                        return self.logger.log(level: .info, category: .payments, message: "Unknown categoryPicker type \(String(describing: categoryPicker))", file: #file, line: #line)
                    }
                    
                    categoryPicker.content.event(.loaded(categories ?? []))
                    
                    self.logger.log(level: .info, category: .network, message: "==== Loaded \(categories?.count ?? 0) categories", file: #file, line: #line)
                }
            }
        }
        
        let hasCorporateCardsOnlyPublisher = model.products.map(\.hasCorporateCardsOnly).eraseToAnyPublisher()
        
        let loadBannersList = makeLoadBanners()
        
        let paymentsTransfersCorporate = makePaymentsTransfersCorporate(
            bannerPickerPlaceholderCount: 6,
            nanoServices: .init(
                loadBanners: loadBannersList
            )
        )
        
        let mainViewBannersBinder = makeBannersForMainView(
            bannerPickerPlaceholderCount: 6,
            nanoServices: .init(
                loadBanners: loadBannersList,
                // TODO: add real serial model.localAgent.serial(for: LandingType.self)
                loadLandingByType: { getLanding(( "", $0), $1) }
            )
        )
        
        // call and notify bannerPicker
        bindings.saveAndRun {
            
            loadBannersList {
                
                guard let paymentsTransfersBannerPicker = paymentsTransfersCorporate.content.bannerPicker.bannerBinder
                else { return }
                
                paymentsTransfersBannerPicker.content.event(.loaded($0))
                mainViewBannersBinder.content.bannerPicker.content.event(.loaded($0))
            }
        }
        
        let paymentsTransfersSwitcher = PaymentsTransfersSwitcher(
            hasCorporateCardsOnly: hasCorporateCardsOnlyPublisher,
            corporate: paymentsTransfersCorporate,
            personal: paymentsTransfersPersonal,
            scheduler: schedulers.main
        )
        
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
        
        let rootViewModel = make(
            paymentsTransfersFlag: paymentsTransfersFlag,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeTemplates: makeMakeTemplates(paymentsTransfersFlag),
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
            collateralLoanLandingFlag: collateralLoanLandingFlag,
            onRegister: resetCVVPINActivation,
            makePaymentProviderPickerFlowModel: makeSegmentedPaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder,
            paymentsTransfersSwitcher: paymentsTransfersSwitcher,
            bannersBinder: mainViewBannersBinder,
            marketShowcaseBinder: marketShowcaseBinder
        )
        
        let marketBinder = MarketShowcaseToRootViewModelBinder(
            marketShowcase: rootViewModel.tabsViewModel.marketShowcaseBinder,
            rootViewModel: rootViewModel,
            scheduler: schedulers.main
        )
        
        bindings.formUnion(marketBinder.bind())
        
        let witness = RootViewDomain.ContentWitnesses(
            isFlagActive: paymentsTransfersFlag == .active
        )
        
        let composer = RootViewDomain.BinderComposer(
            bindings: bindings,
            dismiss: dismiss,
            getNavigation: getRootNavigation,
            bindOutside: { $1.bindOutside(to: $0, on: self.schedulers.main) },
            schedulers: schedulers,
            witnesses: .init(content: witness, dismiss: .default)
        )
        
        return composer.compose(with: rootViewModel)
    }
}

private extension RootViewDomain.Flow {
    
    func bindOutside(
        to content: RootViewDomain.Content,
        on scheduler: AnySchedulerOfDispatchQueue
    ) -> Set<AnyCancellable> {
        
        let outside = $state.compactMap(\.outside)
            .debounce(for: .milliseconds(500), scheduler: scheduler)
            .receive(on: scheduler)
            .sink { [weak content] in
                
                guard let content else { return }
                
                switch $0 {
                case let .productProfile(productID):
                    content.tabsViewModel.mainViewModel.action.send(MainViewModelAction.Show.ProductProfile(productId: productID))
                    
                case let .tab(tab):
                    switch tab {
                    case .main:
                        content.selected = .main

                    case .payments:
                        content.selected = .payments
                    }
                }
            }
        
        return [outside]
    }
}

private extension FlowState<RootViewNavigation> {
    
    var outside: RootViewOutside? {
        
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
    typealias Operator = UtilityPaymentOperator
    
    typealias UtilityPaymentViewModel = AnywayTransactionViewModel
    typealias MakePTFlowManger = (RootViewModel.RootActions.Spinner?) -> PaymentsTransfersFlowManager
    
    typealias MakeProductProfileViewModel = (ProductData, String, FilterState, @escaping () -> Void) -> ProductProfileViewModel?
    
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
        makeSubscriptionsViewModel: @escaping UserAccountNavigationStateManager.MakeSubscriptionsViewModel,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        makePaymentProviderPickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderPickerFlowModel,
        makePaymentProviderServicePickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderServicePickerFlowModel,
        makeServicePaymentBinder: @escaping PaymentsTransfersFactory.MakeServicePaymentBinder
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
                makeSubscriptionsViewModel: makeSubscriptionsViewModel,
                updateInfoStatusFlag: updateInfoStatusFlag,
                makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
                makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
                makeServicePaymentBinder: makeServicePaymentBinder
            )
            
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
                makeSections: { model.makeSections(flag: updateInfoStatusFlag) },
                makeServicePaymentBinder: makeServicePaymentBinder,
                makeTemplates: makeTemplates,
                makeUtilitiesViewModel: makeUtilitiesViewModel
            )
            
            let makeOperationDetailViewModel: OperationDetailFactory.MakeOperationDetailViewModel = { productStatementData, productData, model in
                
                return .init(
                    productStatement: productStatementData,
                    product: productData,
                    updateFastAll: {
                        model.action.send(ModelAction.Products.Update.Fast.All())
                    },
                    model: model
                )
            }
            
            let operationDetailFactory = OperationDetailFactory(
                makeOperationDetailViewModel: makeOperationDetailViewModel
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
                makeSubscriptionsViewModel: makeSubscriptionsViewModel,
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
                dismissAction: dismissAction
            )
        }
    }
}

// TODO: needs better naming
private extension RootViewModelFactory {
    
    func makeLoggingStore<Key>(
        store: any Store<Key>
    ) -> any Store<Key> {
        
        let log = { self.logger.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        
        return LoggingStoreDecorator(
            decoratee: store,
            log: log
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
        paymentsTransfersFlag: PaymentsTransfersFlag,
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
        collateralLoanLandingFlag: CollateralLoanLandingFlag,
        onRegister: @escaping OnRegister,
        makePaymentProviderPickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderPickerFlowModel,
        makePaymentProviderServicePickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderServicePickerFlowModel,
        makeServicePaymentBinder: @escaping PaymentsTransfersFactory.MakeServicePaymentBinder,
        paymentsTransfersSwitcher: PaymentsTransfersSwitcher,
        bannersBinder: BannersBinder,
        marketShowcaseBinder: MarketShowcaseDomain.Binder
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
            makeUtilitiesViewModel: makeUtilitiesViewModel
        )
        
        let mainViewModel = MainViewModel(
            model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            navigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            landingServices: landingServices,
            paymentsTransfersFactory: paymentsTransfersFactory,
            updateInfoStatusFlag: updateInfoStatusFlag,
            onRegister: onRegister,
            bannersBinder: bannersBinder,
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
            
            switch paymentsTransfersFlag.rawValue {
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
                    rootActions: $0,
                    onRegister: onRegister
                )
            )
            
            return RootViewModelAction.Cover.ShowLogin(viewModel: loginViewModel)
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

private extension Error {
    
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
