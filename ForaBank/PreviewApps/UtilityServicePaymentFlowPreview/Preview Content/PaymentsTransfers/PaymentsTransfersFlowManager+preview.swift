//
//  PaymentsTransfersFlowManager+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

extension PaymentsTransfersFlowManager {
    
    static func preview(
        startPaymentStub: UtilityPrepaymentFlowEffectHandler.StartPaymentResult? = nil
    ) -> Self {
        
        let effectHandler = PaymentsTransfersEffectHandler.preview(
            startPaymentStub: startPaymentStub
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
