//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Combine
import Foundation
import ForaTools
import ManageSubscriptionsUI
import OperatorsListComponents
import PaymentSticker
import RemoteServices
import SberQR
import SwiftUI
import PayHub
import PayHubUI
import Fetcher
import LandingUIComponent
import LandingMapping
import CodableLanding
import CalendarUI

extension RootViewModelFactory {
    
    typealias MakeOperationStateViewModel = (@escaping PaymentSticker.BusinessLogic.SelectOffice) -> OperationStateViewModel
    
    static func make(
        model: Model,
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        bindings: inout Set<AnyCancellable>,
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        historyFilterFlag: HistoryFilterFlag,
        changeSVCardLimitsFlag: ChangeSVCardLimitsFlag,
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag,
        marketplaceFlag: MarketplaceFlag,
        paymentsTransfersFlag: PaymentsTransfersFlag,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        mainScheduler: AnySchedulerOfDispatchQueue = .main,
        interactiveScheduler: AnySchedulerOfDispatchQueue = .global(qos: .userInteractive),
        backgroundScheduler: AnySchedulerOfDispatchQueue = .global(qos: .userInitiated)
    ) -> RootViewModel {
        
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
            store: KeyTagKeyChainStore<RSADomain.KeyPair>(
                keyTag: .rsa
            ),
            logger: logger
        )
        
        let resetCVVPINActivation = makeResetCVVPINActivation(
            rsaKeyPairStore: rsaKeyPairStore,
            logger: logger
        )
        
        let cvvPINServicesClient = Services.cvvPINServicesClient(
            httpClient: httpClient,
            logger: logger,
            rsaKeyPairStore: rsaKeyPairStore
        )
        
        let infoNetworkLog = { logger.log(level: .info, category: .network, message: $0, file: $1, line: $2) }
        
        let fpsHTTPClient = fastPaymentsSettingsFlag.isStub
        ? HTTPClientStub.fastPaymentsSettings()
        : httpClient
        
        // TODO: Remove after `legacy` case eliminated
        let fastPaymentsFactory: FastPaymentsFactory = {
            
            switch fastPaymentsSettingsFlag.rawValue {
            case .active:
                return .init(fastPaymentsViewModel: .new({
                    
                    makeNewFastPaymentsViewModel(
                        httpClient: fpsHTTPClient,
                        model: model,
                        log: infoNetworkLog,
                        scheduler: $0
                    )
                }))
                
            case .inactive:
                return .init(fastPaymentsViewModel: .legacy({
                    
                    .init(model: $0,newModel: model,closeAction: $1)
                }))
            }
        }()
        
        let userAccountNavigationStateManager = makeNavigationStateManager(
            modelEffectHandler: .init(model: model),
            otpServices: .init(fpsHTTPClient, infoNetworkLog),
            fastPaymentsFactory: fastPaymentsFactory,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel(
                getProducts: getSubscriptionProducts(model: model),
                c2bSubscription: model.subscriptions.value,
                scheduler: mainScheduler
            ),
            duration: fastPaymentsSettingsFlag.isStub ? 10 : 60,
            log: infoNetworkLog,
            scheduler: mainScheduler
        )
        
        let sberQRServices = Services.makeSberQRServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let qrViewModelFactory = makeQRViewModelFactory(
            model: model,
            logger: logger,
            qrResolverFeatureFlag: qrResolverFeatureFlag,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: mainScheduler
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
                model.action.send(ModelAction.Informer.Show(informer: .init(message: $0, icon: .check)))
            }
        )
        
        let controlPanelModelEffectHandler = ControlPanelModelEffectHandler(
            cancelC2BSub: { (token: SubscriptionViewModel.Token) in
                
                let action = ModelAction.C2B.CancelC2BSub.Request(token: token)
                model.action.send(action)
            })
        
        let historyEffectHandlerMicroServices = HistoryEffectHandlerMicroServices(
            makeFilterModel: { payload, completion in
                
                let reducer = FilterModelReducer()
                let composer = FilterEffectHandlerMicroServicesComposer(model: model)
                let filterEffectHandler = FilterModelEffectHandler(
                    microServices: composer.compose()
                )
                let services = model.historyCategories(productId: payload.productId)
                let viewModel = FilterViewModel(
                    initialState: .init(
                        productId: payload.productId,
                        calendar: .init(
                            date: Date(),
                            range: .init(range: payload.range),
                            monthsData: .generate(startDate: model.calendarDayStart(payload.productId)),
                            periods: FilterHistoryState.Period.allCases
                        ),
                        filter: .init(
                            title: "Фильтры",
                            selectDates: payload.range, 
                            selectedPeriod: .dates,
                            selectedServices: payload.selectedServices,
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
        
        let templatesComposer = makeTemplatesComposer(
            paymentsTransfersFlag: paymentsTransfersFlag,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
            scheduler: mainScheduler
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
        
        let makePaymentProviderPickerFlowModel = makePaymentProviderPickerFlowModel(
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
            model: model,
            flag: utilitiesPaymentsFlag.optionOrStub,
            scheduler: mainScheduler
        )
        
        let makePaymentProviderServicePickerFlowModel = makeProviderServicePickerFlowModel(
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
            model: model,
            flag: utilitiesPaymentsFlag.optionOrStub,
            scheduler: mainScheduler
        )
        
        let makeProductProfileViewModel = ProductProfileViewModel.make(
            with: model,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makeTemplates: makeTemplates,
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            productProfileServices: productProfileServices,
            qrViewModelFactory: qrViewModelFactory,
            cvvPINServicesClient: cvvPINServicesClient,
            productNavigationStateManager: productNavigationStateManager,
            makeCardGuardianPanel: makeCardGuardianPanel,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel(
                getProducts: getSubscriptionProducts(model: model),
                c2bSubscription: model.subscriptions.value,
                scheduler: mainScheduler
            ),
            updateInfoStatusFlag: updateInfoStatusFlag,
            makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder
        )
        
        // TODO: let errorErasedNanoServiceComposer: RemoteNanoServiceFactory = LoggingRemoteNanoServiceComposer...
        // reusable factory
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        // reusable component
        let asyncLocalAgent = LocalAgentAsyncWrapper(
            agent: model.localAgent,
            interactiveScheduler: interactiveScheduler,
            backgroundScheduler: backgroundScheduler
        )
        // reusable factory
        let batchSerialComposer = BatchSerialCachingRemoteLoaderComposer(
            nanoServiceFactory: nanoServiceComposer,
            updateMaker: asyncLocalAgent
        )
        // reusable factory
        let serialLoaderComposer = SerialLoaderComposer(
            asyncLocalAgent: asyncLocalAgent,
            nanoServiceComposer: nanoServiceComposer
        )
        
        let (serviceCategoriesLocalLoad, serviceCategoriesRemoteLoad) = serialLoaderComposer.compose(
            getSerial: { model.localAgent.serial(for: [CodableServiceCategory].self) },
            fromModel: [ServiceCategory].init(codable:),
            toModel: [CodableServiceCategory].init(categories:),
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetServiceCategoryListResponse
        )
        
        let localServiceCategoryLoader = ServiceCategoryLoader.default
        let getServiceCategoryList = NanoServices.makeGetServiceCategoryList(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        let getServiceCategoryListLoader = AnyLoader { completion in
            
            backgroundScheduler.delay(for: .seconds(2)) {
                
                getServiceCategoryList(nil) {
                    
                    completion($0.map(\.list))
                }
            }
        }
        let decorated = CacheDecorator(
            decoratee: getServiceCategoryListLoader,
            cache: localServiceCategoryLoader.save
        )
        let loadServiceCategories: LoadServiceCategories = { completion in
            
            decorated.load {
                
                let categories = (try? $0.get()) ?? []
                completion(categories.map { .category($0)})
            }
        }
        
        let getLatestPayments = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
        let _makeLoadLatestOperations = makeLoadLatestOperations(
            getAllLoadedCategories: localServiceCategoryLoader.load,
            getLatestPayments: getLatestPayments
        )
        let loadLatestOperations = _makeLoadLatestOperations(.all)
        
        let paymentsTransfersPersonal = makePaymentsTransfersPersonal(
            model: model,
            categoryPickerPlaceholderCount: 6,
            operationPickerPlaceholderCount: 4,
            nanoServices: .init(
                loadCategories: loadServiceCategories,
                loadAllLatest: loadLatestOperations,
                loadLatestForCategory: { getLatestPayments([$0.name], $1) },
                loadOperators: { _, completion in completion(.success([])) }
            ),
            mainScheduler: mainScheduler,
            backgroundScheduler: backgroundScheduler
        )
        
        let operatorsService = batchSerialComposer.composeServicePaymentProviderService(
            getSerial: { _ in
                
                model.localAgent.serial(for: [CodableServicePaymentProvider].self)
            }
        )
        
        let oneTime = FireAndForgetDecorator(
            decoratee: loadServiceCategories,
            decoration: { [weak paymentsTransfersPersonal] response, completion in
                
                // notify categoryPicker
                paymentsTransfersPersonal?.content.categoryPicker.content.event(.loaded(response))
                
                // load operators
                let categories = response.categories
                let serial = model.localAgent.serial(for: [CodableServicePaymentProvider].self)
                
                operatorsService(categories.map { .init(serial: serial, category: $0) }) {
                    
                    if !$0.isEmpty {
                        
                        logger.log(level: .error, category: .network, message: "Failed to load operators for categories: \($0.map(\.category))", file: #file, line: #line)
                    }
                }
                
                completion()
            }
        )

        bindings.saveAndRun {
            
            oneTime {
                
                guard let items = try? $0.get() else { return }

                logger.log(level: .error, category: .network, message: "Failed to load operators for categories: \(items.categories)", file: #file, line: #line)
            }
        }
        
        let hasCorporateCardsOnlyPublisher = model.products.map(\.hasCorporateCardsOnly).eraseToAnyPublisher()
                
        let loadBannersList = makeBannersBinder(
            model: model,
            httpClient: httpClient,
            infoNetworkLog: infoNetworkLog,
            mainScheduler: mainScheduler,
            backgroundScheduler: backgroundScheduler
        )

        let paymentsTransfersCorporate = makePaymentsTransfersCorporate(
            bannerPickerPlaceholderCount: 6,
            nanoServices: .init(
                loadBanners: loadBannersList
            ),
            mainScheduler: mainScheduler,
            backgroundScheduler: backgroundScheduler
        )
        
        let getLanding = nanoServiceComposer.compose(
            createRequest: RequestFactory.createMarketplaceLandingRequest,
            mapResponse: LandingMapper.map
        )

        let bannersBinder = makeBannersForMainView(
            bannerPickerPlaceholderCount: 6,
            nanoServices: .init(
                loadBanners: loadBannersList, 
                // TODO: add real serial model.localAgent.serial(for: LandingType.self)
                loadLandingByType: { getLanding(( "", $0), $1) }
            ),
            mainScheduler: mainScheduler,
            backgroundScheduler: backgroundScheduler
        )

        // call and notify bannerPicker
        bindings.saveAndRun {
            
            loadBannersList {
                
                paymentsTransfersCorporate.content.bannerPicker.content.event(.loaded($0))
                bannersBinder.content.bannerPicker.content.event(.loaded($0))
            }
        }

        let paymentsTransfersSwitcher = PaymentsTransfersSwitcher(
            hasCorporateCardsOnly: hasCorporateCardsOnlyPublisher,
            corporate: paymentsTransfersCorporate,
            personal: paymentsTransfersPersonal,
            scheduler: mainScheduler
        )
        _ = oneTime
        return make(
            paymentsTransfersFlag: paymentsTransfersFlag,
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeTemplates: makeTemplates,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            productNavigationStateManager: productNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            updateInfoStatusFlag: updateInfoStatusFlag,
            onRegister: resetCVVPINActivation,
            makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder,
            paymentsTransfersSwitcher: paymentsTransfersSwitcher,
            bannersBinder: bannersBinder
        )
    }
    
    static func makeNavigationOperationView(
        httpClient: HTTPClient,
        model: Model,
        dismissAll: @escaping() -> Void
    ) -> () -> some View {
        
        return makeNavigationOperationView
        
        func operationView(
            setSelection: (@escaping (Location, @escaping NavigationFeatureViewModel.Completion) -> Void)
        ) -> some View {
            
            let makeOperationStateViewModel = makeOperationStateViewModel(
                httpClient,
                model: model
            )
            
            return OperationView(
                model: makeOperationStateViewModel(setSelection),
                operationResultView: { result in
                    
                    OperationResultView(
                        model: result,
                        buttonsView: makeStickerDetailDocumentButtons(
                            httpClient: httpClient,
                            model: model
                        ),
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
    
    static func makeStickerDetailDocumentButtons(
        httpClient: HTTPClient,
        model: Model
    ) -> (
        PaymentSticker.OperationResult.PaymentID
    ) -> some View {
        
        let makeDetailButton = makeOperationDetailButton(
            httpClient: httpClient,
            model: model
        )
        
        let makeDocumentButton = makeDocumentButton(
            httpClient: httpClient,
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
    
    typealias MakeProductProfileViewModel = (ProductData, String, FilterState, @escaping () -> Void) -> ProductProfileViewModel?
    
    static func make(
        with model: Model,
        fastPaymentsFactory: FastPaymentsFactory,
        makeUtilitiesViewModel: @escaping MakeUtilitiesViewModel,
        makeTemplates: @escaping PaymentsTransfersFactory.MakeTemplates,
        makePaymentsTransfersFlowManager: @escaping MakePTFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
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
                        direction: .custom(start: lowerDate.addingTimeInterval(10800), end: upperDate.addingTimeInterval(97199)),
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
    
    static func makeLoggingStore<Key>(
        store: any Store<Key>,
        logger: LoggerAgentProtocol
    ) -> any Store<Key> {
        
        let log = { logger.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        
        return LoggingStoreDecorator(
            decoratee: store,
            log: log
        )
    }
    
    typealias ResetCVVPINActivation = () -> Void
    
    static func makeResetCVVPINActivation(
        rsaKeyPairStore: any Store<RSADomain.KeyPair>,
        logger: LoggerAgentProtocol
    ) -> ResetCVVPINActivation {
        
        return rsaKeyPairStore.deleteCacheIgnoringResult
    }
    
    typealias MakeProductProfileViewModel = (ProductData, String, FilterState, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnRegister = () -> Void
    typealias MakePTFlowManger = (RootViewModel.RootActions.Spinner?) -> PaymentsTransfersFlowManager
    
    static func make(
        paymentsTransfersFlag: PaymentsTransfersFlag,
        model: Model,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        makeTemplates: @escaping PaymentsTransfersFactory.MakeTemplates,
        fastPaymentsFactory: FastPaymentsFactory,
        makeUtilitiesViewModel: @escaping MakeUtilitiesViewModel,
        makePaymentsTransfersFlowManager: @escaping MakePTFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        productNavigationStateManager: ProductProfileFlowManager,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        onRegister: @escaping OnRegister,
        makePaymentProviderPickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderPickerFlowModel,
        makePaymentProviderServicePickerFlowModel: @escaping PaymentsTransfersFactory.MakePaymentProviderServicePickerFlowModel,
        makeServicePaymentBinder: @escaping PaymentsTransfersFactory.MakeServicePaymentBinder,
        paymentsTransfersSwitcher: PaymentsTransfersSwitcher,
        bannersBinder: BannersBinder

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
            makeSections: { model.makeSections(flag: updateInfoStatusFlag) },
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
                    model,
                    rootActions: $0,
                    onRegister: onRegister
                )
            )
            
            return RootViewModelAction.Cover.ShowLogin(viewModel: loginViewModel)
        }
        
        return .init(
            fastPaymentsFactory: fastPaymentsFactory,
            navigationStateManager: userAccountNavigationStateManager,
            productNavigationStateManager: productNavigationStateManager,
            mainViewModel: mainViewModel,
            paymentsModel: paymentsModel,
            chatViewModel: chatViewModel,
            informerViewModel: informerViewModel,
            model,
            showLoginAction: showLoginAction
        )
    }
}

// MARK: - Adapters

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

extension Array where Element == CategoryPickerSectionItem<ServiceCategory> {
    
    var categories: [ServiceCategory] {
        
        compactMap {
            
            switch $0 {
            case let .category(category):
                return category
                
            case .showAll:
                return .none
            }
        }
    }
}
