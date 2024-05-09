//
//  PaymentsTransfersFlowManager+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

extension PaymentsTransfersFlowManager
where LastPayment == UtilityServicePaymentFlowPreview.LastPayment,
      Operator == UtilityServicePaymentFlowPreview.Operator,
      UtilityService == UtilityServicePaymentFlowPreview.UtilityService,
      Content == UtilityPrepaymentViewModel,
      PaymentViewModel == ObservingPaymentFlowMockViewModel {

    typealias EffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    static func preview(
        startPaymentStub: EffectHandler.StartPaymentResult? = nil
    ) -> Self {
        
        typealias EffectHandler = PaymentsTransfersFlowEffectHandler
        
        let effectHandler = EffectHandler.preview(
            startPaymentStub: startPaymentStub
        )
        
        typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
        
        let makeReducer = { notify in
            
            Reducer(factory: .preview, notify: notify)
        }
        return .init(
            handleEffect: effectHandler.handleEffect(_:_:),
            makeReduce: { makeReducer($0).reduce(_:_:) }
        )
    }
}
