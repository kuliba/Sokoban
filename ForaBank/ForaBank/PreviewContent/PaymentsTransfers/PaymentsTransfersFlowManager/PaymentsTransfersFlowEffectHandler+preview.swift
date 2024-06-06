//
//  PaymentsTransfersFlowEffectHandler+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import ForaTools
import Foundation
import OperatorsListComponents

extension PaymentsTransfersFlowEffectHandler
where LastPayment == UtilityPaymentLastPayment,
      Operator == UtilityPaymentOperator,
      Service == UtilityService {
    
    static func preview(
    ) -> Self {
        
        typealias UtilityPrepaymentEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, Service>
        
        let utilityPrepaymentEffectHandler = UtilityPrepaymentEffectHandler(
            microServices: .preview
        )
        
        typealias EffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, Service>
        
        let effectHandler = EffectHandler(
            utilityPrepaymentEffectHandle: utilityPrepaymentEffectHandler.handleEffect(_:_:)
        )
        
        return .init(
            utilityEffectHandle: effectHandler.handleEffect(_:_:)
        )
    }
}
