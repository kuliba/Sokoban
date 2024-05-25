//
//  PaymentsTransfersFlowComposer.swift
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

final class PaymentsTransfersFlowComposer {
    
    private let flag: StubbedFeatureFlag.Option
    private let httpClient: HTTPClient
    private let log: Log
    private let model: Model
    private let loaderComposer: LoaderComposer
    private let pageSize: Int
    private let observeLast: Int
    
    init(
        flag: StubbedFeatureFlag.Option,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        pageSize: Int,
        observeLast: Int
    ) {
        self.flag = flag
        self.httpClient = httpClient
        self.log = log
        self.model = model
        self.loaderComposer = .init(flag: flag, model: model, pageSize: pageSize)
        self.pageSize = pageSize
        self.observeLast = observeLast
    }
}

extension PaymentsTransfersFlowComposer {
    
    func compose() -> FlowManager {
        
        return .init(
            handleEffect: makeEffectHandler().handleEffect(_:_:),
            makeReduce: makeReduce()
        )
    }
    
    typealias Log = (String, StaticString, UInt) -> Void
    
    typealias LoaderComposer = UtilityPaymentOperatorLoaderComposer
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias Content = UtilityPrepaymentViewModel
    typealias PaymentViewModel = ObservingAnywayTransactionViewModel
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

private extension PaymentsTransfersFlowComposer {
    
    func makeEffectHandler() -> EffectHandler {
        
        let loadOperators = loaderComposer.compose()
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: composerFlag,
            httpClient: httpClient,
            log: log,
            loadOperators: { loadOperators(.init(), $0) }
        )
        let microComposer = UtilityPrepaymentFlowMicroServicesComposer(
            nanoServices: nanoComposer.compose()
        )
        let prepaymentEffectHandler = PrepaymentFlowEffectHandler(
            microServices: microComposer.compose()
        )
        let paymentFlowEffectHandler = PaymentFlowEffectHandler(
            utilityPrepaymentEffectHandle: prepaymentEffectHandler.handleEffect(_:_:)
        )
        
        return .init(utilityEffectHandle: paymentFlowEffectHandler.handleEffect(_:_:))
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    typealias PaymentFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>

    private var composerFlag: ComposerFlag {
        
        switch flag {
        case .live:
            return .live
            
        case .stub:
            return .stub(stub)
        }
    }
    
    typealias ComposerFlag = UtilityPaymentNanoServicesComposer.Flag
    
    typealias EffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, UtilityService>
    
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
        let load = loaderComposer.compose()
        load(
            .init(
                operatorID: payload.operatorID,
                searchText: payload.searchText),
            completion
        )
    }
    
    private typealias LoadOperatorsPayload = UtilityPrepaymentNanoServices<Operator>.LoadOperatorsPayload
    
    private func makeTransactionViewModel(
        initialState: AnywayTransactionState
    ) -> AnywayTransactionViewModel {
        
        let composer = AnywayTransactionViewModelComposer(
            flag: flag, 
            httpClient: httpClient,
            log: log
        )
        
        return composer.compose(initialState: initialState)
    }
}

// MARK: - Stubs

private extension PaymentsTransfersFlowComposer {
    
    func stub(
        for payload: UtilityPaymentNanoServices<LastPayment, Operator>.StartAnywayPaymentPayload
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch payload {
        case let .lastPayment(lastPayment):
            return stub(for: lastPayment)
            
        case let .service(service, for: `operator`):
            return stub(for: service)
        }
    }
    
    typealias PrepaymentMicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator, UtilityService>
    
    private func stub(
        for lastPayment: LastPayment
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch lastPayment.id {
        case "failure":
            return .failure(.serviceFailure(.connectivityError))
            
        default:
            return .success(.startPayment(.preview))
        }
    }
    
    private func stub(
        for `operator`: Operator
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch `operator`.id {
        case "single":
            return .success(.startPayment(.preview))
            
        case "singleFailure":
            return .failure(.operatorFailure(`operator`))
            
        case "multiple":
            let services = MultiElementArray<UtilityService>([
                .init(name: UUID().uuidString, puref: "failure"),
                .init(name: UUID().uuidString, puref: UUID().uuidString),
            ])!
            return .success(.services(services, for: `operator`))
            
        case "multipleFailure":
            return .failure(.serviceFailure(.serverError("Server Failure")))
            
        default:
            return .success(.startPayment(.preview))
        }
    }
    
    private func stub(
        for service: UtilityService
    ) -> PrepaymentMicroServices.StartPaymentResult {
        
        switch service.id {
        case "failure":
            return .failure(.serviceFailure(.serverError("Server Failure")))
            
        default:
            return .success(.startPayment(.preview))
        }
    }
}
