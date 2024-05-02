//
//  UtilityServicePaymentFlowEffectHandler.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

final class UtilityServicePaymentFlowEffectHandler {}

extension UtilityServicePaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension UtilityServicePaymentFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityServicePaymentFlowEvent
    typealias Effect = UtilityServicePaymentFlowEffect
}
