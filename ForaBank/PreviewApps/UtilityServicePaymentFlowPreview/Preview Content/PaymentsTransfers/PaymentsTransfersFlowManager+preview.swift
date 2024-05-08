//
//  PaymentsTransfersFlowManager+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

extension PaymentsTransfersFlowManager
where Content == UtilityPrepaymentViewModel,
      PaymentViewModel == ObservingPaymentFlowMockViewModel {
    
    static func preview(
        startPaymentStub: UtilityPrepaymentFlowEffectHandler.StartPaymentResult? = nil
    ) -> Self {
        
        typealias EffectHandler = PaymentsTransfersFlowEffectHandler<Content, PaymentViewModel>
        
        let effectHandler = EffectHandler.preview(
            startPaymentStub: startPaymentStub
        )
        
        typealias Reducer = PaymentsTransfersFlowReducer<Content, PaymentViewModel>
        
        let makeReducer = { notify in
            
            Reducer(factory: .preview, notify: notify)
        }
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0).reduce(_:_:) }
        )
    }
}
