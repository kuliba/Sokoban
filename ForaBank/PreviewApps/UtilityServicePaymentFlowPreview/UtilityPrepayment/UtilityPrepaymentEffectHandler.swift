//
//  UtilityPrepaymentEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

final class UtilityPrepaymentEffectHandler {}

extension UtilityPrepaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension UtilityPrepaymentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPrepaymentEvent
    typealias Effect = UtilityPrepaymentEffect
}
