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
import RemoteServices
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

final class PaymentsTransfersFlowManagerComposer {
    
    private let flag: Flag
    private let model: Model
    private let httpClient: HTTPClient
    private let log: Log
    private let pageSize: Int
    private let observeLast: Int
    
    init(
        flag: Flag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        pageSize: Int,
        observeLast: Int
    ) {
        self.flag = flag
        self.model = model
        self.httpClient = httpClient
        self.log = log
        self.pageSize = pageSize
        self.observeLast = observeLast
    }
    
    typealias Flag = UtilitiesPaymentsFlag
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension PaymentsTransfersFlowManagerComposer {
    
    func compose() -> FlowManager {
        
        return .init(
            handleEffect: makeHandleEffect(),
            makeReduce: makeReduce()
        )
    }
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingAnywayTransactionViewModel
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
    
    typealias PaymentFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    private func composePrepaymentFlowEffectHandler(
    ) -> PrepaymentFlowEffectHandler {
        
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: composerFlag,
            model: model,
            httpClient: httpClient,
            log: log,
            loadOperators: loadOperators
        )
        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            flag: flag.rawValue,
            nanoServices: nanoComposer.compose(),
            makeLegacyPaymentsServicesViewModel: makeLegacyPaymentsServicesViewModel
        )
        
        return .init(microServices: microComposer.compose())
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    private var composerFlag: ComposerFlag {
        
        switch flag.rawValue {
        case .active(.live):
            return .live
            
        case .inactive, .active(.stub):
            return .stub(stub)
        }
    }
    
    typealias ComposerFlag = UtilityPaymentNanoServicesComposer.Flag
    
    private func loadOperators(
        _ completion: @escaping ([Operator]) -> Void
    ) {
        let load = loadOperators()
        
        load(.init()) { completion($0); _ = load }
    }
    
    private func makeLegacyPaymentsServicesViewModel(
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
    
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
    typealias PrepaymentEffect = Effect.UtilityPrepaymentFlowEffect
    typealias MakePaymentPayload = PrepaymentEffect.LegacyPaymentPayload
    
    func makeReduce() -> FlowManager.MakeReduce {
        
        let factory = makeReducerFactoryComposer().compose()
        
        typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
        
        let makeReducer = {
            
            Reducer(factory: factory, closeAction: $0, notify: $1)
        }
        
        return { makeReducer($0, $1).reduce(_:_:) }
    }
    
    private func makeReducerFactoryComposer(
    ) -> PaymentsTransfersFlowReducerFactoryComposer {
        
        let nanoServices = UtilityPrepaymentNanoServices(
            loadOperators: loadOperators
        )
        let microComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: pageSize,
            nanoServices: nanoServices
        )
        
        return .init(
            model: model,
            observeLast: observeLast,
            microServices: microComposer.compose(),
            makeTransactionViewModel: makeTransactionViewModel
        )
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
            pageSize: pageSize
        )
        
        return loaderComposer.compose()
    }
    
    private func makeTransactionViewModel(
        initialState: AnywayTransactionState
    ) -> AnywayTransactionViewModel {
        
        let composer = AnywayTransactionViewModelComposer(
            flag: flag.optionOrStub,
            httpClient: httpClient,
            log: log
        )
        
        return composer.compose(initialState: initialState)
    }
}

// MARK: - Stubs

private extension PaymentsTransfersFlowManagerComposer {
    
    func stub(
        payload: ComposerFlag.Payload
    ) -> ComposerFlag.StartPaymentResult {
        
        switch payload {
        case let .lastPayment(lastPayment):
            switch lastPayment.id {
            case "failure":
                return .failure(.serviceFailure(.connectivityError))
                
            default:
                return .success(.startPayment(.preview))
            }
            
        case let .service(service, _):
            switch service.id {
            case "failure":
                return .failure(.serviceFailure(.serverError("Server Failure")))
                
            default:
                return .success(.startPayment(.preview))
            }
        }
    }
}

private extension AnywayTransactionState {
    
    static var preview: Self {
        
        return .init(payment: .preview, isValid: true)
    }
}

private extension AnywayPaymentContext {
    
    static var preview: Self {
        
        return .init(payment: .preview, staged: [], outline: .preview, shouldRestart: false)
    }
}

private extension AnywayPaymentDomain.AnywayPayment {
    
    static var preview: Self {
        
        return .init(elements: [], infoMessage: nil, isFinalStep: false, isFraudSuspected: false, puref: "")
    }
}

private extension AnywayPaymentOutline {
    
    static var preview: Self {
        
        return .init(core: .preview, fields: [:])
    }
}

private extension AnywayPaymentOutline.PaymentCore {
    
    static var preview: Self {
        
        return .init(amount: 0, currency: "RUB", productID: 1, productType: .account)
    }
}

private extension RemoteServices.ResponseMapper.CreateAnywayTransferResponse {
    
    static var preview: Self {
        
        return .init(additional: [], finalStep: false, needMake: false, needOTP: false, needSum: false, parametersForNextStep: [], options: [])
    }
}
