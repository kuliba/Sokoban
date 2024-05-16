//
//  UtilityPaymentsFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import ForaTools
import Foundation
//import OperatorsListComponents

final class UtilityPaymentsFlowComposer {
    
    private let flag: Flag
    private let microServices: MicroServices
    
    init(
        flag: Flag,
        microServices: MicroServices
    ) {
        self.flag = flag
        self.microServices = microServices
    }
}

extension UtilityPaymentsFlowComposer {
    
    typealias Flag = StubbedFeatureFlag.Option
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias MicroServices = UtilityPaymentMicroServices<LastPayment, Operator>
}

extension UtilityPaymentsFlowComposer {
    
    func makeEffectHandler(
    ) -> UtilityFlowEffectHandler {
        
        let prepaymentEffectHandler = PrepaymentFlowEffectHandler(
            initiateUtilityPayment: microServices.initiateUtilityPayment,
            startPayment: startPayment()
        )
        
        return .init(
            utilityPrepaymentEffectHandle: prepaymentEffectHandler.handleEffect(_:_:)
        )
    }
}

extension UtilityPaymentsFlowComposer {
    
    typealias UtilityFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}

private extension UtilityPaymentsFlowComposer {
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    func startPayment(
    ) -> PrepaymentFlowEffectHandler.StartPayment {
        
        switch flag {
        case .live:
            fatalError("unimplemented live")
            
        case .stub:
            return stub()
        }
    }
}

// MARK: - Stubs

private extension UtilityPaymentsFlowComposer {
    
    typealias PrepaymentPayload = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    
    func stub(
        _ stub: PrepaymentPayload
    ) -> PrepaymentFlowEffectHandler.InitiateUtilityPayment {
        
        return { completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    func stub() -> PrepaymentFlowEffectHandler.StartPayment {
        
        return { payload, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub(for: payload))
            }
        }
        
        func stub(
            for payload: PrepaymentFlowEffectHandler.StartPaymentPayload
        ) -> PrepaymentFlowEffectHandler.StartPaymentResult {
            
            switch payload {
            case let .lastPayment(lastPayment):
                switch lastPayment.id {
                case "failure":
                    return .failure(.serviceFailure(.connectivityError))
                    
                default:
                    return .success(.startPayment(.init()))
                }
                
            case let .operator(`operator`):
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
                
            case let .service(service, _):
                switch service.id {
                case "failure":
                    return .failure(.serviceFailure(.serverError("Server Failure")))
                    
                default:
                    return .success(.startPayment(.init()))
                }
            }
        }
    }
}
