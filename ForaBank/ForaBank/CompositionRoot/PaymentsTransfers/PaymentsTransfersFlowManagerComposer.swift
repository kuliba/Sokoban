//
//  PaymentsTransfersFlowManagerComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentBackend
import AnywayPaymentCore
import AnywayPaymentDomain
import OperatorsListComponents
import ForaTools
import Foundation
import GenericRemoteService
import PaymentComponents
import RemoteServices
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

final class PaymentsTransfersFlowManagerComposer {
    
    private let flag: Flag
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    
    init(
        flag: Flag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log
    ) {
        self.flag = flag
        self.model = model
        self.httpClient = httpClient
        self.log = log
    }
    
    typealias Flag = UtilitiesPaymentsFlag
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension PaymentsTransfersFlowManagerComposer {
    
    func compose(
        _ spinnerActions: RootViewModel.RootActions.Spinner?
    ) -> FlowManager {
        
        let composer = makeReducerFactoryComposer()
        let factory = composer.compose(
            makeUtilityPaymentState: makeUtilityPaymentState(
                with: spinnerActions
            )
        )
        
        return .init(
            handleEffect: makeHandleEffect(),
            makeReduce: makeReduce(with: factory)
        )
    }
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, Service, Content, PaymentViewModel>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = AnywayTransactionViewModel
}

private extension PaymentsTransfersFlowManagerComposer {
    
    struct Settings: Equatable {
        
        let pageSize: Int = 50
        let observeLast: Int = 10
        let fraudDelay: Double
        let utilityNavTitle = "Услуги ЖКХ"
        
        static let live: Self = .init(fraudDelay: 120)
        static let stub: Self = .init(fraudDelay: 12)
    }
    
    var settings: Settings {
        
        flag.isStub ? .stub : .live
    }
}

private extension PaymentsTransfersFlowManagerComposer {
    
    func makeHandleEffect() -> FlowManager.HandleEffect {
        
        let paymentFlowEffectHandler = composePaymentFlowEffectHandler()
        
        let effectHandler = PaymentsTransfersFlowEffectHandler(
            utilityEffectHandle: paymentFlowEffectHandler.handleEffect(_:_:)
        )
        
        return effectHandler.handleEffect(_:_:)
    }
    
    private func composePaymentFlowEffectHandler(
    ) -> PaymentFlowEffectHandler {
        
        let prepaymentEffectHandler = composePrepaymentFlowEffectHandler()
        
        return .init(
            utilityPrepaymentEffectHandle: prepaymentEffectHandler.handleEffect(_:_:)
        )
    }
    
    typealias PaymentFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, Service>
    
    private func composePrepaymentFlowEffectHandler(
    ) -> PrepaymentFlowEffectHandler {
        
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: flag,
            model: model,
            httpClient: httpClient,
            log: log,
            loadOperators: loadOperators
        )
        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            flag: flag.rawValue,
            nanoServices: nanoComposer.compose(),
            makeLegacyPaymentsServicesViewModel: makeLegacyViewModel
        )
        
        return .init(microServices: microComposer.compose())
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, Service>
    
    private func loadOperators(
        _ completion: @escaping ([Operator]) -> Void
    ) {
        let load = loadOperators()
        
        load(.init()) { completion($0); _ = load }
    }
    
    private func makeLegacyViewModel(
        payload: MakePaymentPayload
    ) -> PaymentsServicesViewModel {
        
        let operators = model.operators(for: payload.type) ?? []
        
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
    
    typealias PrepaymentEffect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
    typealias MakePaymentPayload = PrepaymentEffect.LegacyPaymentPayload
    
    func makeReduce(
        with factory: ReducerFactory
    ) -> FlowManager.MakeReduce {
        
        let makeReducer = {
            
            FlowReducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return { makeReducer($0, $1).reduce(_:_:) }
    }
    
    typealias ReducerFactory = PaymentsTransfersFlowReducerFactory<LastPayment, Operator, Service, Content, PaymentViewModel>
    typealias FlowReducer = PaymentsTransfersFlowReducer<LastPayment, Operator, Service, Content, PaymentViewModel>
    
    private func makeReducerFactoryComposer(
    ) -> PaymentsTransfersFlowReducerFactoryComposer {
        
        let nanoServices = UtilityPrepaymentNanoServices(
            loadOperators: loadOperators
        )
        let microComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: settings.pageSize,
            nanoServices: nanoServices
        )
        
        return .init(
            model: model,
            settings: .init(
                observeLast: settings.observeLast,
                fraudDelay: settings.fraudDelay,
                navTitle: settings.utilityNavTitle
            ),
            microServices: microComposer.compose()
        )
    }
    
    typealias MakeTransactionViewModel = (AnywayTransactionState, @escaping Observe) -> AnywayTransactionViewModel
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
    
    func makeUtilityPaymentState(
        with spinnerActions: RootViewModel.RootActions.Spinner?
    ) -> (AnywayTransactionState.Transaction, @escaping NotifyStatus) -> UtilityServicePaymentFlowState<AnywayTransactionViewModel> {
        
        let elementMapper = AnywayElementModelMapper(
            currencyOfProduct: currencyOfProduct,
            format: format,
            getProducts: model.productSelectProducts,
            flag: flag.optionOrStub
        )
        
        let microServices = composeMicroServices()
        
        let composer = AnywayTransactionViewModelComposer(
            getCurrencySymbol: getCurrencySymbol,
            elementMapper: elementMapper,
            microServices: microServices,
            spinnerActions: spinnerActions
        )
        
        return { transaction, notify in
            
            let viewModel = composer.makeAnywayTransactionViewModel(
                transaction: transaction
            )
            
            let subscription = viewModel.$state
                .dropFirst()
                .map(\.transaction.status)
                .removeDuplicates()
                .handleEvents(receiveOutput: {
#if DEBUG || MOCK
                    print("===>>>", ObjectIdentifier(viewModel), "notify: viewModel.$state.transaction.status:", $0 ?? "nil", "\(#file):\(#line)")
#endif
                })
                .sink(receiveValue: notify)
            
            return .init(viewModel: viewModel, subscription: subscription)
        }
    }
    
    private func format(currency: String?, amount: Decimal) -> String {
        
        return model.formatted(amount, with: currency ?? "") ?? ""
    }
    
    private func composeMicroServices(
    ) -> AnywayTransactionEffectHandlerMicroServices {
        
        typealias NanoServicesComposer = AnywayTransactionEffectHandlerNanoServicesComposer
        typealias MicroServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer
        
        let nanoServicesComposer = NanoServicesComposer(
            flag: flag.optionOrStub,
            httpClient: httpClient,
            log: log
        )
        
        let microServicesComposer = MicroServicesComposer(
            nanoServices: nanoServicesComposer.compose()
        )
        
        return microServicesComposer.compose()
    }
    
    private func getCurrencySymbol(
        for currency: String
    ) -> String {
        
        model.dictionaryCurrencySymbol(for: currency) ?? ""
    }
    
    typealias NotifyStatus = (AnywayTransactionStatus?) -> Void
    
    private func currencyOfProduct(
        product: ProductSelect.Product
    ) -> String {
        
        model.currencyOf(product: product) ?? ""
    }
    
    private func loadOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([Operator]) -> Void
    ) {
        let load = loadOperators()
        
        typealias Payload = UtilityPaymentOperatorLoaderComposer.Payload
        
        let payload = Payload(
            operatorID: payload.operatorID,
            searchText: payload.searchText
        )
        
        load(payload) { completion($0); _ = load }
    }
    
    typealias LoadOperatorsPayload = UtilityPrepaymentNanoServices<Operator>.LoadOperatorsPayload
    
    private func loadOperators(
    ) -> (
        UtilityPaymentOperatorLoaderComposer.Payload,
        @escaping ([Operator]) -> Void
    ) -> Void {
        
        let loaderComposer = UtilityPaymentOperatorLoaderComposer(
            flag: flag.optionOrStub,
            model: model,
            pageSize: settings.pageSize
        )
        
        return loaderComposer.compose()
    }
}
