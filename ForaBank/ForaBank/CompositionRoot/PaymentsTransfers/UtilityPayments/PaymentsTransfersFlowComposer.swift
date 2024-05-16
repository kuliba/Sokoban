//
//  PaymentsTransfersFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents
import ForaTools
import Foundation
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
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

private extension PaymentsTransfersFlowComposer {
    
    func makeEffectHandler() -> EffectHandler {
        
        let nanoComposer = UtilityPaymentNanoServicesComposer(
            flag: composerFlag,
            httpClient: httpClient,
            log: log,
            loadOperators: { self.loaderComposer.compose()(.init(), $0) }
        )
        let microComposer = UtilityPaymentMicroServicesComposer(
            nanoServices: nanoComposer.compose()
        )
        let composer = UtilityPaymentsFlowComposer(
            microServices: microComposer.compose()
        )
        let utilityEffectHandler = composer.makeEffectHandler()
        
        return .init(
            utilityEffectHandle: utilityEffectHandler.handleEffect(_:_:)
        )
    }
    
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
            microServices: microComposer.compose()
        )
    }
    
    private func loadOperators(
        payload: LoadOperatorsPayload,
        completion: @escaping ([Operator]) -> Void
    ) {
        loaderComposer.compose()(.init(operatorID: payload.operatorID, searchText: payload.searchText), completion)
    }
    
    private typealias LoadOperatorsPayload = UtilityPrepaymentNanoServices<Operator>.LoadOperatorsPayload
}

// MARK: - Stubs

private extension PaymentsTransfersFlowComposer {
    
    func stub(
        for payload: PrepaymentFlowEffectHandler.StartPaymentPayload
    ) -> PrepaymentFlowEffectHandler.StartPaymentResult {
        
        switch payload {
        case let .lastPayment(lastPayment):
            return stub(for: lastPayment)
            
        case let .operator(`operator`):
            return stub(for: `operator`)
            
        case let .service(service, _):
            return stub(for: service)
        }
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    private func stub(
        for lastPayment: LastPayment
    ) -> PrepaymentFlowEffectHandler.StartPaymentResult {
        
        switch lastPayment.id {
        case "failure":
            return .failure(.serviceFailure(.connectivityError))
            
        default:
            return .success(.startPayment(.init()))
        }
    }
    
    private func stub(
        for `operator`: Operator
    ) -> PrepaymentFlowEffectHandler.StartPaymentResult {
        
        switch `operator`.id {
        case "single":
            return .success(.startPayment(.init()))
            
        case "singleFailure":
            return .failure(.operatorFailure(`operator`))
            
        case "multiple":
            let services = MultiElementArray<UtilityService>([
                .init(id: "failure"),
                .init(id: UUID().uuidString),
            ])!
            return .success(.services(services, for: `operator`))
            
        case "multipleFailure":
            return .failure(.serviceFailure(.serverError("Server Failure")))
            
        default:
            return .success(.startPayment(.init()))
        }
    }
    
    private func stub(
        for service: UtilityService
    ) -> PrepaymentFlowEffectHandler.StartPaymentResult {
        
        switch service.id {
        case "failure":
            return .failure(.serviceFailure(.serverError("Server Failure")))
            
        default:
            return .success(.startPayment(.init()))
        }
    }
}
