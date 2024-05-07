//
//  PaymentsTransfersFlowManager+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation
import ForaTools

extension PaymentsTransfersFlowManager {
    
    static func preview(
        startPaymentStub: UtilityPaymentFlowEffectHandler.StartPaymentResult? = nil
    ) -> Self {
        
        let utilityFlowEffectHandler = UtilityPaymentFlowEffectHandler(
            initiateUtilityPayment: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.preview)
                }
            },
            startPayment: { payload, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(startPaymentStub ?? .stub(for: payload))
                }
            }
        )
        
        let effectHandler = PaymentsTransfersEffectHandler(
            utilityEffectHandle: utilityFlowEffectHandler.handleEffect(_:_:)
        )
        
        let makeReducer = { notify in
            
            PaymentsTransfersReducer(factory: .preview, notify: notify)
        }
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0).reduce(_:_:) }
        )
    }
}

private extension UtilityPaymentFlowEffectHandler.StartPaymentResult {
    
    static func stub(
        for payload: UtilityPaymentFlowEffectHandler.StartPaymentPayload,
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
    
    static let preview: Self = .success(.startPayment(.init()))
}

private extension MultiElementArray where Element == UtilityService {
    
    static let preview: Self = .init([
        
        .init(id: "failure"),
        .init(id: UUID().uuidString),
    ])!
}
