//
//  PaymentsTransfersEffectHandler.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

final class PaymentsTransfersEffectHandler {
    
    private let utilityPaymentFlowHandleEffect: UtilityPaymentFlowHandleEffect
    
    init(
        utilityPaymentFlowHandleEffect: @escaping UtilityPaymentFlowHandleEffect
    ) {
        self.utilityPaymentFlowHandleEffect = utilityPaymentFlowHandleEffect
    }
}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .utilityPayment(flowEffect):
            utilityPaymentFlowHandleEffect(flowEffect) {
                
                dispatch(.utilityPayment($0))
            }
        }
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, PaymentsTransfersEvent.StartPayment, UtilityService>
    typealias UtilityFlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator>
    typealias UtilityFlowDispatch = (UtilityFlowEvent) -> Void
    typealias UtilityPaymentFlowHandleEffect = (UtilityFlowEffect, @escaping UtilityFlowDispatch) -> Void

    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
