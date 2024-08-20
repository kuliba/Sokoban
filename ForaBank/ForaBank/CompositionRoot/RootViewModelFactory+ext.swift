//
//  RootViewModelFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2023.
//

import Foundation
import ForaTools
import ManageSubscriptionsUI
import OperatorsListComponents
import PaymentSticker
import SberQR
import SwiftUI
import PayHub

extension RootViewModelFactory {
    
    typealias MakeOperationStateViewModel = (@escaping PaymentSticker.BusinessLogic.SelectOffice) -> OperationStateViewModel
    
    static func make(
        model: Model,
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        historyFilterFlag: HistoryFilterFlag,
        changeSVCardLimitsFlag: ChangeSVCardLimitsFlag,
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag,
        paymentsTransfersFlag: PaymentsTransfersFlag,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) -> RootViewModel {
        
        let httpClient: HTTPClient = model.authenticatedHTTPClient()
        
        let cachelessHTTPClient = model.cachelessAuthorizedHTTPClient()
        
        if getProductListByTypeV6Flag.isActive {
            model.getProductsV6 = Services.getProductListByTypeV6(cachelessHTTPClient, logger: logger)
        } else {
            model.getProducts = Services.getProductListByType(cachelessHTTPClient, logger: logger)
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
            qrResolverFeatureFlag: qrResolverFeatureFlag,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: scheduler
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
        
        let productNavigationStateManager = ProductProfileFlowManager(
            reduce: makeProductProfileFlowReducer().reduce(_:_:),
            handleEffect: ProductNavigationStateEffectHandler().handleEffect,
            handleModelEffect: controlPanelModelEffectHandler.handleEffect
        )
        
        let templatesComposer = makeTemplatesComposer(
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
            scheduler: scheduler
        )
        let makeTemplates = templatesComposer.compose
        
        let ptfmComposer = PaymentsTransfersFlowManagerComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: scheduler
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
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: scheduler
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
            flag: utilitiesPaymentsFlag,
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
            scheduler: scheduler
        )
        
        let makePaymentProviderPickerFlowModel = makePaymentProviderPickerFlowModel(
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
            model: model,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: scheduler
        )
        
        let makePaymentProviderServicePickerFlowModel = makeProviderServicePickerFlowModel(
            httpClient: httpClient,
            log: logger.log(level:category:message:file:line:),
            model: model,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: scheduler
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
                scheduler: scheduler
            ),
            updateInfoStatusFlag: updateInfoStatusFlag,
            makePaymentProviderPickerFlowModel: makePaymentProviderPickerFlowModel,
            makePaymentProviderServicePickerFlowModel: makePaymentProviderServicePickerFlowModel,
            makeServicePaymentBinder: makeServicePaymentBinder
        )
        
        final class ServiceCategoryStore {
            
            var categories: [ServiceCategory]
            
            init(
                categories: [ServiceCategory] = []
            ) {
                self.categories = categories
            }
        }
        
        let serviceCategoryStore = ServiceCategoryStore()
        let serviceCategoryLoader = AnyLoader { completion in
            
            completion(serviceCategoryStore.categories)
        }
        
        let _makeLoadLatestOperations = makeLoadLatestOperations(
            getAllLoadedCategories: serviceCategoryLoader.load,
            getLatestPayments: NanoServices.getLatestPayments
        )
        let loadLatestOperations = _makeLoadLatestOperations(.all)
        
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
            loadLatestOperations: loadLatestOperations,
            scheduler: scheduler
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
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
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
        
        return { product, rootView, dismissAction in
            
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
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
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
        loadLatestOperations: @escaping LoadLatestOperations,
        scheduler: AnySchedulerOfDispatchQueue
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
            onRegister: onRegister
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
                let binder = makePaymentsTransfersBinder(
                    loadLatestOperations: loadLatestOperations,
                    scheduler: scheduler
                )
                return .v1(binder)
                
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
