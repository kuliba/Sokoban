//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Foundation
import ManageSubscriptionsUI
import OperatorsListComponents
import PaymentSticker
import SberQR
import SwiftUI

extension RootViewModelFactory {
    
    typealias MakeOperationStateViewModel = (@escaping PaymentSticker.BusinessLogic.SelectOffice) -> OperationStateViewModel
    
    static func make(
        httpClient: HTTPClient,
        model: Model,
        logger: LoggerAgentProtocol,
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) -> RootViewModel {
        
        model.getProducts = Services.getProductListByType(httpClient, logger: logger)

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
                scheduler: scheduler
            ),
            duration: fastPaymentsSettingsFlag.isStub ? 10 : 60,
            log: infoNetworkLog,
            scheduler: scheduler
        )
        
        let sberQRServices = Services.makeSberQRServices(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let qrViewModelFactory = makeQRViewModelFactory(
            model: model,
            logger: logger,
            qrResolverFeatureFlag: qrResolverFeatureFlag
        )
        
        let utilitiesHTTPClient = utilitiesPaymentsFlag.isStub
        ? HTTPClientStub.utilityPayments()
        : httpClient
        
        let makeUtilitiesViewModel = makeUtilitiesViewModel(
            httpClient: utilitiesHTTPClient,
            model: model,
            log: infoNetworkLog,
            isActive: utilitiesPaymentsFlag.isActive
        )
        
        let paymentsTransfersNavigationStateManager = makePaymentsTransfersNavigationStateManager(
        )

        let productNavigationStateManager = makeProductNavigationStateManager(
            alertsReduce: AlertReducer(productAlertsViewModel: .default),
            handleEffect: ProductNavigationStateEffectHandler()
        )

        let makeProductProfileViewModel = ProductProfileViewModel.make(
            with: model,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            paymentsTransfersNavigationStateManager: paymentsTransfersNavigationStateManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            cvvPINServicesClient: cvvPINServicesClient, 
            productNavigationStateManager: productNavigationStateManager
        )
        
        return make(
            model: model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            fastPaymentsFactory: fastPaymentsFactory,
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            paymentsTransfersNavigationStateManager: paymentsTransfersNavigationStateManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            productNavigationStateManager: productNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            onRegister: resetCVVPINActivation
        )
    }
    
    static func makeUtilitiesViewModel(
        httpClient: HTTPClient,
        model: Model,
        log: @escaping (String, StaticString, UInt) -> Void,
        isActive: Bool
    ) -> MakeUtilitiesViewModel {
        
        return { payload, completion in
            
            switch payload.type {
            case .internet:
                makeLegacyUtilitiesViewModel(payload, model)
                    .map(PaymentsTransfersFactory.UtilitiesVM.legacy)
                    .map(completion)
                
            case .service:
                if isActive {
                    makeUtilitiesViewModel(httpClient, model, log, completion)
                } else {
                    makeLegacyUtilitiesViewModel(payload, model)
                        .map(PaymentsTransfersFactory.UtilitiesVM.legacy)
                        .map(completion)
                }
                
            default:
                return
            }
        }
    }
    
    static func makeUtilitiesViewModel(
        _ httpClient: HTTPClient,
        _ model: Model,
        _ log: @escaping (String, StaticString, UInt) -> Void,
        _ completion: @escaping (PaymentsTransfersFactory.UtilitiesVM) -> Void
    ) {
        
#warning("connect solution from MR")
        // from https://git.inn4b.ru/dbs/ios/-/merge_requests/1800
        // model.loadOperators
        let loadOperators: UtilitiesViewModel.LoadOperators = { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion([
                    .failure,
                    .list,
                    .single,
                ])
            }
        }
        
        /*
         rest/v2/getAllLatestPayments?isServicePayments=true
         https://shorturl.at/suCL9
         
         let getAllLatestPayments = NanoServices.adaptedLoggingFetch(
         createRequest: { fatalError() },
         httpClient: httpClient,
         mapResponse: { _,_ in fatalError() },
         mapResult: { (try? $0.get()) ?? [] }, // mapResult to non-Result type!!
         log: log
         )
         */
        
#warning("connect real type; move typealiases")
        
        typealias GetAllLatestPaymentsCompletion = ([OperatorsListComponents.LatestPayment]) -> Void
        typealias GetAllLatestPayments = (@escaping GetAllLatestPaymentsCompletion) -> Void
        
        let getAllLatestPayments: GetAllLatestPayments = { completion in
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion([])
            }
        }
        
        getAllLatestPayments { latestPayments in
            
            loadOperators(.init()) { operators in
                
                let viewModel = UtilitiesViewModel(
                    initialState: .init(
                        lastPayments: latestPayments,
                        operators: operators
                    ),
                    loadOperators: loadOperators
                )
                
                completion(.utilities(viewModel))
            }
        }
    }
    
    static func makeLegacyUtilitiesViewModel(
        _ payload: PaymentsTransfersFactory.MakeUtilitiesPayload,
        _ model: Model
    ) -> PaymentsServicesViewModel? {
        
        guard let operators = model.operators(for: payload.type)
        else { return nil }
        
        let navigationBarViewModel = NavigationBarView.ViewModel.allRegions(
            titleButtonAction: { [weak model] in
                
                model?.action.send(PaymentsServicesViewModelWithNavBarAction.OpenCityView())
            },
            navLeadingAction: payload.navLeadingAction,
            navTrailingAction: payload.navTrailingAction
        )
        
        let lastPaymentsKind: LatestPaymentData.Kind = .init(rawValue: payload.type.rawValue) ?? .unknown
        let latestPayments = PaymentsServicesLatestPaymentsSectionViewModel(model: model, including: [lastPaymentsKind])
        
        return .init(
            searchBar: .withText("Наименование или ИНН"),
            navigationBar: navigationBarViewModel,
            model: model,
            latestPayments: latestPayments,
            allOperators: operators,
            addCompanyAction: payload.addCompany,
            requisitesAction: payload.requisites
        )
    }
    
    static func makePaymentsTransfersNavigationStateManager(
    ) -> PaymentsTransfersNavigationStateManager {
        
        let createAnywayTransfer: PaymentsTransfersEffectHandler.CreateAnywayTransfer = { payload, completion in
            
#warning("replace with NanoService.createAnywayTransfer")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                switch payload {
                case let .latestPayment(latestPayment):
                    completion(.details(.init()))
                    
                case let .service(`operator`, utilityService):
                    switch utilityService.id {
                    case "server error":
                        completion(.serverError("Error [#12345]."))
                        
                    case "empty", "just sad":
                        completion(.failure)
                        
                    default:
                        completion(.details(.init()))
                    }
                }
            }
        }
        
        let getOperatorsListByParam: PaymentsTransfersEffectHandler.GetOperatorsListByParam = { payload, completion in
            
#warning("replace with NanoService.getOperatorsListByParam")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                switch payload {
                case "list":
                    completion(.list([
                        .init(id: "happy"),
                        .init(id: "server error"),
                        .init(id: "empty"),
                        .init(id: "just sad"),
                    ]))
                    
                case "single":
                    completion(.single(.init()))
                    
                default:
                    completion(.failure)
                }
            }
        }
        
        let effectHandler = PaymentsTransfersEffectHandler(
            createAnywayTransfer: createAnywayTransfer,
            getOperatorsListByParam: getOperatorsListByParam
        )
        
        let utilityPaymentReducer = UtilityPaymentReducer()
        
        return .init(
            utilityPaymentReduce: utilityPaymentReducer.reduce(_:_:),
            reduce: { _,_ in fatalError() },
            handleEffect: effectHandler.handleEffect
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
            model: model
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

private extension NavigationBarView.ViewModel {
    
    static func allRegions(
        titleButtonAction: @escaping () -> Void,
        navLeadingAction: @escaping () -> Void,
        navTrailingAction: @escaping () -> Void
    ) -> NavigationBarView.ViewModel {
        
        .init(
            title: PaymentsServicesViewModel.allRegion,
            titleButton: .init(
                icon: .ic24ChevronDown,
                action: titleButtonAction
            ),
            leftItems: [
                NavigationBarView.ViewModel.BackButtonItemViewModel(
                    icon: .ic24ChevronLeft,
                    action: navLeadingAction
                )
            ],
            rightItems: [
                NavigationBarView.ViewModel.ButtonItemViewModel(
                    icon: Image("qr_Icon"),
                    action: navTrailingAction
                )
            ]
        )
    }
}

typealias MakeUtilitiesViewModel = PaymentsTransfersFactory.MakeUtilitiesViewModel

extension ProductProfileViewModel {
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
    static func make(
        with model: Model,
        fastPaymentsFactory: FastPaymentsFactory,
        makeUtilitiesViewModel: @escaping MakeUtilitiesViewModel,
        paymentsTransfersNavigationStateManager: PaymentsTransfersNavigationStateManager,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        cvvPINServicesClient: CVVPINServicesClient,
        productNavigationStateManager: ProductNavigationStateManager
    ) -> MakeProductProfileViewModel {
        
        return { product, rootView, dismissAction in
            
            let makeProductProfileViewModel = ProductProfileViewModel.make(
                with: model,
                fastPaymentsFactory: fastPaymentsFactory,
                makeUtilitiesViewModel: makeUtilitiesViewModel,
                paymentsTransfersNavigationStateManager: paymentsTransfersNavigationStateManager,
                userAccountNavigationStateManager: userAccountNavigationStateManager,
                sberQRServices: sberQRServices,
                qrViewModelFactory: qrViewModelFactory,
                cvvPINServicesClient: cvvPINServicesClient, 
                productNavigationStateManager: productNavigationStateManager
            )
            
            let makeTemplatesListViewModel: PaymentsTransfersFactory.MakeTemplatesListViewModel = {
                
                .init(
                    model,
                    dismissAction: $0,
                    updateFastAll: {
                        model.action.send(ModelAction.Products.Update.Fast.All())
                    })
            }
            
            let paymentsTransfersFactory = PaymentsTransfersFactory(
                makeUtilitiesViewModel: makeUtilitiesViewModel,
                makeProductProfileViewModel: makeProductProfileViewModel,
                makeTemplatesListViewModel: makeTemplatesListViewModel
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
            
            let makeProductProfileViewModelFactory: ProductProfileViewModelFactory = .init(makeInfoProductViewModel: {
                
                return .init(
                    model: $0.model,
                    product: $0.productData,
                    info: $0.info,
                    showCvv: $0.showCVV,
                    event: $0.events
                )
                
            })
            return .init(
                model,
                fastPaymentsFactory: fastPaymentsFactory,
                paymentsTransfersNavigationStateManager: paymentsTransfersNavigationStateManager,
                userAccountNavigationStateManager: userAccountNavigationStateManager,
                sberQRServices: sberQRServices,
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

private extension Model {
    
    func operators(
        for type: PTSectionPaymentsView.ViewModel.PaymentsType
    ) -> [OperatorGroupData.OperatorData]? {
        
        guard let dictionaryAnywayOperators = dictionaryAnywayOperators(),
              let operatorValue = Payments.operatorByPaymentsType(type)
        else { return nil }
        #warning("suboptimal sort + missing sort condition")
        // TODO: fix sorting: remove excessive iterations
        // TODO: fix sorting according to https://shorturl.at/ehxIQ
        return  dictionaryAnywayOperators
            .filter { $0.parentCode == operatorValue.rawValue }
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .sorted(by: { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending })
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
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    typealias OnRegister = () -> Void
    
    static func make(
        model: Model,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        fastPaymentsFactory: FastPaymentsFactory,
        makeUtilitiesViewModel: @escaping MakeUtilitiesViewModel,
        paymentsTransfersNavigationStateManager: PaymentsTransfersNavigationStateManager,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        productNavigationStateManager: ProductNavigationStateManager,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        onRegister: @escaping OnRegister
    ) -> RootViewModel {
        
        let makeTemplatesListViewModel: PaymentsTransfersFactory.MakeTemplatesListViewModel = {
            
            .init(
                model,
                dismissAction: $0,
                updateFastAll: {
                    model.action.send(ModelAction.Products.Update.Fast.All())
                })
        }
        
        let paymentsTransfersFactory = PaymentsTransfersFactory(
            makeUtilitiesViewModel: makeUtilitiesViewModel,
            makeProductProfileViewModel: makeProductProfileViewModel,
            makeTemplatesListViewModel: makeTemplatesListViewModel
        )
                
        let mainViewModel = MainViewModel(
            model,
            makeProductProfileViewModel: makeProductProfileViewModel,
            navigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            paymentsTransfersFactory: paymentsTransfersFactory,
            onRegister: onRegister
        )
        
        let paymentsViewModel = PaymentsTransfersViewModel(
            model: model,
            navigationStateManager: paymentsTransfersNavigationStateManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            paymentsTransfersFactory: paymentsTransfersFactory
        )
        
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
            paymentsViewModel: paymentsViewModel,
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

// MARK: - Stubs

private extension OperatorsListComponents.Operator {
    
    static let failure: Self = .init("failure", "Failure")
    static let list: Self = .init("list", "List")
    static let single: Self = .init("single", "Single")
    
    private init(_ id: String, _ title: String) {
        
        self.init(id: id, title: title, subtitle: nil, image: nil)
    }
}
