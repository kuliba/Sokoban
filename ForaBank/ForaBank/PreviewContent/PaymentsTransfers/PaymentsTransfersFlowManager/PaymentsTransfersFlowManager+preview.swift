//
//  PaymentsTransfersFlowManager+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

extension PaymentsTransfersFlowManager
where LastPayment == OperatorsListComponents.LatestPayment,
      Operator == OperatorsListComponents.Operator,
      UtilityService == ForaBank.UtilityService,
      Content == UtilityPrepaymentViewModel,
      PaymentViewModel == ObservingPaymentFlowMockViewModel {
    
    typealias EffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    static var preview: Self {
        
        typealias EffectHandler = PaymentsTransfersFlowEffectHandler
        
        let effectHandler = EffectHandler.preview()
        
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
