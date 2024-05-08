//
//  PaymentsTransfersFlowManager+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

extension PaymentsTransfersFlowManager
where UtilityPrepaymentViewModel == UtilityServicePaymentFlowPreview.UtilityPrepaymentViewModel,
      PaymentViewModel == ObservingPaymentFlowMockViewModel {
    
    static func preview(
        startPaymentStub: UtilityPrepaymentFlowEffectHandler.StartPaymentResult? = nil
    ) -> Self {
        
        typealias EffectHandler = PaymentsTransfersEffectHandler<UtilityPrepaymentViewModel, PaymentViewModel>
        
        let effectHandler = EffectHandler.preview(
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
