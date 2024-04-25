//
//  PaymentFlowEffectHandler.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentFlowEffectHandler {}

extension PaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiateUtilityPayment:
            initiateUtilityPayment()
        }
    }
}

extension PaymentFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentFlowEvent
    typealias Effect = PaymentFlowEffect
}

private extension PaymentFlowEffectHandler {
    
    func initiateUtilityPayment() {
        
        fatalError()
    }
}
