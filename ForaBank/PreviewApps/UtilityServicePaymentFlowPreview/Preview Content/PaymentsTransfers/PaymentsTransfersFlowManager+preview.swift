//
//  PaymentsTransfersFlowManager+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

extension PaymentsTransfersFlowManager {
    
    static func preview(
        selectStub: PaymentsTransfersEffectHandler.SelectResult? = nil
    ) -> Self {
        
        let effectHandler = PaymentsTransfersEffectHandler(
            select: { payload, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(selectStub ?? .stub(for: payload))
                }
            }
        )
        
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

private extension PaymentsTransfersEffectHandler.SelectResult {
    
    static func stub(
        for payload: PaymentsTransfersEffectHandler.SelectPayload,
        fallback: Self = .preview
    ) -> Self {
        
        switch payload {
        case let .lastPayment(lastPayment):
            switch lastPayment.id {
            case "last": return 1
            default:     return fallback
            }
            
        case let .operator(`operator`):
            switch `operator`.id {
            case "single":          return 1
            case "singleFailure":   return 2
            case "multiple":        return 3
            case "multipleFailure": return 4
            default:                return fallback
            }
        }
    }
    
    static let preview: Self = .init()
}

