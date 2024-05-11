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
where LastPayment == OperatorsListComponents.LastPayment,
      Operator == OperatorsListComponents.Operator,
      UtilityService == ForaBank.UtilityService {
    
    static func preview(
    ) -> Self {
        
        typealias UtilityPrepaymentEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
        
        let utilityPrepaymentEffectHandler = UtilityPrepaymentEffectHandler(
            initiateUtilityPayment: { _ in },
            startPayment: { _,_ in }
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
