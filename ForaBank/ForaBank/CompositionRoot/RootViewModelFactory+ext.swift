//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import AnywayPaymentBackend
import CodableLanding
import CollateralLoanLanding
import Combine
import Fetcher
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
        bindings: inout Set<AnyCancellable>,
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        historyFilterFlag: HistoryFilterFlag,
        changeSVCardLimitsFlag: ChangeSVCardLimitsFlag,
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag,
        marketplaceFlag: MarketplaceFlag,
        paymentsTransfersFlag: PaymentsTransfersFlag,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag
    ) -> RootViewModel {
        
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
        
        if marketplaceFlag.isActive {
            model.getBannerCatalogListV2 = Services.getBannerCatalogListV2(httpClient, logger: logger)
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
        
        let fpsHTTPClient = fastPaymentsSettingsFlag.isStub
        ? HTTPClientStub.fastPaymentsSettings()
        : httpClient
        
        // TODO: Remove after `legacy` case eliminated
        let fastPaymentsFactory: FastPaymentsFactory = {
            
            switch fastPaymentsSettingsFlag.rawValue {
            case .active:
                return .init(fastPaymentsViewModel: .new({
                    
                    self.makeNewFastPaymentsViewModel()
                }))
                
            case .inactive:
                return .init(fastPaymentsViewModel: .legacy({
                    
                    .init(model: $0,newModel: self.model,closeAction: $1)
                }))
            }
        }()
        
        let userAccountNavigationStateManager = makeNavigationStateManager(
            modelEffectHandler: .init(model: model),
            otpServices: .init(fpsHTTPClient, infoNetworkLog),
            fastPaymentsFactory: fastPaymentsFactory,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel(
                getProducts: getSubscriptionProducts,
                c2bSubscription: model.subscriptions.value
            ),
            duration: fastPaymentsSettingsFlag.isStub ? 10 : 60
        )
        
        let sberQRServices = Services.makeSberQRServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let qrViewModelFactory = makeQRViewModelFactory(
            qrResolverFeatureFlag: qrResolverFeatureFlag,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag
        )
        
        let utilitiesHTTPClient = utilitiesPaymentsFlag.isStub
        ? HTTPClientStub.utilityPayments()
        : httpClient
        
        let paymentsTransfersFactoryComposer = PaymentsTransfersFactoryComposer(
            model: model
        )
        let makeUtilitiesViewModel = paymentsTransfersFactoryComposer.makeUtilitiesViewModel(
            log: infoNetworkLog,
            isActive: utilitiesPaymentsFlag.isActive
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
        
        let productNavigationStateManager = ProductProfileFlowManager(
            reduce: makeProductProfileFlowReducer().reduce(_:_:),
            handleEffect: ProductNavigationStateEffectHandler().handleEffect,
            handleModelEffect: controlPanelModelEffectHandler.handleEffect
        )
        
        let templatesComposer = makeTemplatesComposer(
            paymentsTransfersFlag: paymentsTransfersFlag,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag
        )
        let makeTemplates = templatesComposer.compose
        
        let ptfmComposer = PaymentsTransfersFlowManagerComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: mainScheduler
        )
        
        let makePaymentsTransfersFlowManager = ptfmComposer.compose
        
        let makeCardGuardianPanel: ProductProfileViewModelFactory.MakeCardGuardianPanel = {
            if changeSVCardLimitsFlag.isActive {
                return .fullScreen(.cardGuardian($0, changeSVCardLimitsFlag))
            } else {
                return .bottomSheet(.cardGuardian($0, changeSVCardLimitsFlag))
            }
        }
        
        let servicePaymentBinderComposer = ServicePaymentBinderComposer(
            fraudDelay: 120, // TODO: move `fraudDelay` to some Settings
            flag: utilitiesPaymentsFlag.optionOrStub,
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: mainScheduler
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
            flag: utilitiesPaymentsFlag.optionOrStub,
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
            scheduler: mainScheduler
        )
        
        let makePaymentProviderPickerFlowModel = makeSegmentedPaymentProviderPickerFlowModel(
            flag: utilitiesPaymentsFlag.optionOrStub
        )
        
        let makePaymentProviderServicePickerFlowModel = makeProviderServicePickerFlowModel(
            flag: utilitiesPaymentsFlag.optionOrStub
        )
        
        // TODO: let errorErasedNanoServiceComposer: RemoteNanoServiceFactory = LoggingRemoteNanoServiceComposer...
        // reusable factory
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        
        let getLanding = nanoServiceComposer.compose(
            createRequest: RequestFactory.createMarketplaceLandingRequest,
            mapResponse: LandingMapper.map
        )
        
        let makeProductProfileViewModel = ProductProfileViewModel.make(
            with: model,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makeTemplates: makeTemplates,
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            landingServices: .init(loadLandingByType: { getLanding(( "", $0), $1) }),
            productProfileServices: productProfileServices,
            qrViewModelFactory: qrViewModelFactory,
            cvvPINServicesClient: cvvPINServicesClient,
            productNavigationStateManager: productNavigationStateManager,
            makeCardGuardianPanel: makeCardGuardianPanel,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel(
                getProducts: getSubscriptionProducts,
                c2bSubscription: model.subscriptions.value
            ),
            updateInfoStatusFlag: updateInfoStatusFlag,
            makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder
        )
        
        // reusable component
        let asyncLocalAgent = LocalAgentAsyncWrapper(
            agent: model.localAgent,
            interactiveScheduler: interactiveScheduler,
            backgroundScheduler: backgroundScheduler
        )
        // reusable factory
        let batchServiceComposer = SerialCachingRemoteBatchServiceComposer(
            nanoServiceFactory: nanoServiceComposer,
            updateMaker: asyncLocalAgent
        )
        // reusable factory
        let loggingSerialLoaderComposer = LoggingSerialLoaderComposer(
            httpClient: httpClient,
            localAgent: model.localAgent,
            logger: logger
        )
        
        let collateralLoanLandingShowCase = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetCollateralLoanLandingShowCaseRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCollateralLoanShowCaseResponse
        )
        
#warning("extract to a generic namespace")
        typealias ServiceCategoryListLoaderComposer = SerialComponents.SerialLoaderComposer<String, ServiceCategory, CodableServiceCategory>
        typealias ServiceCategoryListRemoteLoad = ServiceCategoryListLoaderComposer.RemoteLoad
        
        let serviceCategoryRemoteLoad: ServiceCategoryListRemoteLoad = nanoServiceComposer.composeSerialResultLoad(
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            mapResponse: ForaBank.ResponseMapper.mapGetServiceCategoryListResponse
        )
        
        let operatorsService = batchServiceComposer.composeServicePaymentOperatorService()
        
        let serviceCategoryListLoaderComposer = ServiceCategoryListLoaderComposer(
            // TODO: replace to use: asyncLocalAgent: asyncLocalAgent,
            localAgent: model.localAgent,
            remoteLoad: backgroundScheduler.scheduled(serviceCategoryRemoteLoad),
            fromModel: { $0.serviceCategory },
            toModel: { $0.codable }
        )
        
        let (serviceCategoryListLoad, serviceCategoryListReload) = serviceCategoryListLoaderComposer.compose()
        
        let decoratedServiceCategoryListReload: Load<[ServiceCategory]> = { completion in
            
            serviceCategoryListReload {
                
                switch $0 {
                case .none:
                    completion(nil)
                    
                case let .some(categories):
                    self.backgroundScheduler.schedule {
    
                        print("==== schedule operatorsService for \(categories.count) categories")
                        
                        let serial = self.model.localAgent.serial(
                            for: [CodableServicePaymentOperator].self
                        )
                        
                        operatorsService(.standard(from: categories, with: serial)) {
                            
                            if !$0.isEmpty {
                                
                                self.logger.log(level: .error, category: .network, message: "Fail to load operators for categories \($0).", file: #file, line: #line)
                            }
                            print("==== operatorsService completion")
                            completion(categories)
                        }
                    }
                }
            }
        }

        let getLatestPayments = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
        let _makeLoadLatestOperations = makeLoadLatestOperations(
            getAllLoadedCategories: { completion in
                
                serviceCategoryListLoad { completion($0 ?? []) }
            },
            getLatestPayments: getLatestPayments
        )
        let loadAllLatestOperations = _makeLoadLatestOperations(.all)
        
        let paymentsTransfersPersonal = makePaymentsTransfersPersonal(
            categoryPickerPlaceholderCount: 6,
            operationPickerPlaceholderCount: 4,
            nanoServices: .init(
                loadCategories: serviceCategoryListLoad,
                reloadCategories: decoratedServiceCategoryListReload,
                loadAllLatest: loadAllLatestOperations,
                loadLatestForCategory: { getLatestPayments([$0.name], $1) }
            ),
            pageSize: 50
        )
        
        if paymentsTransfersFlag.isActive {
            
            performOrWaitForActive {
                
                decoratedServiceCategoryListReload { [weak paymentsTransfersPersonal] categories in
                    
                    let backgroundScheduler = self.backgroundScheduler
                    backgroundScheduler.schedule { [backgroundScheduler] in
                        
                        print("==== decoratedServiceCategoryListReload completion", paymentsTransfersPersonal.map { ObjectIdentifier($0) })
                        
                        // notify categoryPicker
                        paymentsTransfersPersonal?.content.categoryPicker.content.event(.loaded(categories ?? []))
                        
                        self.logger.log(level: .info, category: .network, message: "==== Loaded \(categories?.count ?? 0) categories", file: #file, line: #line)
                        
                        _ = backgroundScheduler // !! DO NOT REMOVE THIS LINE
                    }
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
                
                paymentsTransfersCorporate.content.bannerPicker.content.event(.loaded($0))
                mainViewBannersBinder.content.bannerPicker.content.event(.loaded($0))
            }
        }
        
        let paymentsTransfersSwitcher = PaymentsTransfersSwitcher(
            hasCorporateCardsOnly: hasCorporateCardsOnlyPublisher,
            corporate: paymentsTransfersCorporate,
            personal: paymentsTransfersPersonal,
            scheduler: mainScheduler
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
            scheduler: mainScheduler
        )
        let marketShowcaseBinder = marketShowcaseComposer.compose()
        
        return make(
            paymentsTransfersFlag: paymentsTransfersFlag,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeTemplates: makeTemplates,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            productNavigationStateManager: productNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            landingServices: .init(loadLandingByType: { getLanding(( "", $0), $1) }),
            updateInfoStatusFlag: updateInfoStatusFlag,
            onRegister: resetCVVPINActivation,
            makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder,
            paymentsTransfersSwitcher: paymentsTransfersSwitcher,
            bannersBinder: mainViewBannersBinder,
            marketShowcaseBinder: marketShowcaseBinder
        )
    }
    
    func makeNavigationOperationView(
        dismissAll: @escaping() -> Void
    ) -> () -> some View {
        
        return makeNavigationOperationView
        
        func operationView(
            setSelection: (@escaping (Location, @escaping NavigationFeatureViewModel.Completion) -> Void)
        ) -> some View {
            
            let makeOperationStateViewModel = makeOperationStateViewModel()
            
            return OperationView(
                model: makeOperationStateViewModel(setSelection),
                operationResultView: { result in
                    
                    OperationResultView(
                        model: result,
                        buttonsView: self.makeStickerDetailDocumentButtons(),
                        mainButtonAction: dismissAll,
                        configuration: .default
                    )
                },
                configuration: .default
            )
        }
        
        func dictionaryAtmList(location: Location) -> [AtmData] {
            
            model.dictionaryAtmList()?
                .filter({ $0.cityId.description == location.id })
                .filter({ $0.serviceIdList.contains(where: { $0 == 140 } )}) ?? []
        }
        
        func dictionaryAtmMetroStations() -> [AtmMetroStationData] {
            
            model.dictionaryAtmMetroStations() ?? []
        }
        
        func listView(
            location: Location,
            completion: @escaping (Office?) -> Void
        ) -> some View {
            
            PlacesListInternalView(
                items: dictionaryAtmList(location: location).map { item in
                    PlacesListViewModel.ItemViewModel(
                        id: item.id,
                        name: item.name,
                        address: item.address,
                        metro: dictionaryAtmMetroStations().filter({
                            item.metroStationList.contains($0.id)
                        }).map({
                            PlacesListViewModel.ItemViewModel.MetroStationViewModel(
                                id: $0.id,
                                name: $0.name,
                                color: $0.color.color
                            )
                        }),
                        schedule: item.schedule,
                        distance: nil
                    )
                },
                selectItem: { item in
                    
                    completion(Office(id: item.id, name: item.name))
                }
            )
        }
        
        //NavigationOperationView
        func makeNavigationOperationView() -> some View {
            
            NavigationOperationView(
                location: .init(id: ""),
                viewModel: .init(),
                operationView: operationView,
                listView: listView
            )
        }
    }
    
    func makeStickerDetailDocumentButtons(
    ) -> (
        PaymentSticker.OperationResult.PaymentID
    ) -> some View {
        
        let makeDetailButton = makeOperationDetailButton()
        
        let makeDocumentButton = makeDocumentButton(
            printFormType: .sticker
        )
        
        return make
        
        func make(
            paymentID: PaymentSticker.OperationResult.PaymentID
        ) -> some View {
            
            HStack {
                
                makeDetailButton(.init("\(paymentID.id)"))
                makeDocumentButton(.init(paymentID.id))
            }
        }
    }
}

typealias MakeUtilitiesViewModel = PaymentsTransfersFactory.MakeUtilitiesViewModel

extension ProductProfileViewModel {
    
    typealias LatestPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias UtilityPaymentViewModel = AnywayTransactionViewModel
    typealias MakePTFlowManger = (RootViewModel.RootActions.Spinner?) -> PaymentsTransfersFlowManager
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
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
        
        return { product, rootView, dismissAction in
            
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
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnRegister = () -> Void
    typealias MakePTFlowManger = (RootViewModel.RootActions.Spinner?) -> PaymentsTransfersFlowManager
    
    func make(
        paymentsTransfersFlag: PaymentsTransfersFlag,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        makeTemplates: @escaping PaymentsTransfersFactory.MakeTemplates,
        fastPaymentsFactory: FastPaymentsFactory,
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
            bannersBinder: bannersBinder
        )
        
        let paymentsTransfersViewModel = PaymentsTransfersViewModel(
            model: model,
            makeFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            paymentsTransfersFactory: paymentsTransfersFactory
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
            marketShowcaseBinder: marketShowcaseBinder)
        
        return .init(
            fastPaymentsFactory: fastPaymentsFactory,
            navigationStateManager: userAccountNavigationStateManager,
            productNavigationStateManager: productNavigationStateManager,
            tabsViewModel: tabsViewModel,
            informerViewModel: informerViewModel,
            model,
            showLoginAction: showLoginAction
        )
    }
}

// MARK: - Adapters

private extension Array
where Element == RequestFactory.GetOperatorsListByParamPayload {
    
    static func standard(
        from categories: [ServiceCategory],
        with serial: String?
    ) -> Self {
        
        return categories
            .filter { $0.paymentFlow == .standard }
            .map { .init(serial: serial, category: $0) }
    }
}

private extension UserAccountModelEffectHandler {
    
    convenience init(model: Model) {
        
        self.init(
            cancelC2BSub: { (token: SubscriptionViewModel.Token) in
                
                let action = ModelAction.C2B.CancelC2BSub.Request(token: token)
                model.action.send(action)
            },
            deleteRequest: {
                
                model.action.send(ModelAction.ClientInfo.Delete.Request())
            },
            exit: {
                
                model.auth.value = .unlockRequiredManual
            }
        )
    }
}

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
