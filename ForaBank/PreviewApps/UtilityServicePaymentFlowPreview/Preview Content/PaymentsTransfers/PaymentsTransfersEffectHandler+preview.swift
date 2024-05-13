//
//  PaymentsTransfersFlowEffectHandler+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Foundation
import ForaTools

extension PaymentsTransfersFlowEffectHandler
where LastPayment == UtilityServicePaymentFlowPreview.LastPayment,
      Operator == UtilityServicePaymentFlowPreview.Operator,
      UtilityService == UtilityServicePaymentFlowPreview.UtilityService {
    
    static func preview(
        startPaymentStub: UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>.StartPaymentResult? = nil
    ) -> Self {
        
        typealias UtilityPrepaymentEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
        
        let utilityPrepaymentEffectHandler = UtilityPrepaymentEffectHandler(
            initiateUtilityPayment: { completion in
                
                DispatchQueue.main.delay(for: .seconds(1)) {
                    
                    completion(.preview)
                }
            },
            startPayment: { payload, completion in
                
                DispatchQueue.main.delay(for: .seconds(1)) {
                    
                    completion(startPaymentStub ?? .stub(for: payload))
                }
            }
        )
        
        typealias EffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
        
        let effectHandler = EffectHandler(
            utilityPrepaymentEffectHandle: utilityPrepaymentEffectHandler.handleEffect(_:_:)
        )
        
        return .init(
            utilityEffectHandle: effectHandler.handleEffect(_:_:)
        )
    }
}

private extension UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>.StartPaymentResult {
    
    typealias Payload = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>.StartPaymentPayload
    
    static func stub(
        for payload: Payload,
        fallback: Self = .preview
    ) -> Self {
        
        switch payload {
        case let .lastPayment(lastPayment):
            switch lastPayment.id {
            case "failure": return .failure(.serviceFailure(.connectivityError))
            default:        return .preview
            }
            
        case let .operator(`operator`):
            switch `operator`.id {
            case "single":          return .preview
            case "singleFailure":   return .failure(.operatorFailure(`operator`))
            case "multiple":        return .success(.services(.preview, for: `operator`))
            case "multipleFailure": return .failure(.serviceFailure(.serverError("Server Failure")))
            default:                return fallback
            }
            
        case let .service(service, _):
            switch service.id {
            case "failure": return .failure(.serviceFailure(.serverError("Server Failure")))
            default: return .preview
            }
        }
    }
    
    static var preview: Self { .success(.startPayment(.init())) }
}

private extension MultiElementArray where Element == UtilityService {
    
    static let preview: Self = .init([
        
        .init(id: "failure"),
        .init(id: UUID().uuidString),
    ])!
}
