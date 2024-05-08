//
//  UtilityPaymentFlowEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

final class UtilityPaymentFlowEffectHandler {
    
    private let utilityPrepaymentEffectHandle: UtilityPrepaymentFlowEffectHandle
    
    init(
        utilityPrepaymentEffectHandle: @escaping UtilityPrepaymentFlowEffectHandle
    ) {
        self.utilityPrepaymentEffectHandle = utilityPrepaymentEffectHandle
    }
}

extension UtilityPaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .prepayment(effect):
            utilityPrepaymentEffectHandle(effect) { dispatch(.prepayment($0)) }
        }
    }
}

extension UtilityPaymentFlowEffectHandler {
    
    typealias UtilityPrepaymentFlowDispatch = (Event.UtilityPrepaymentFlowEvent) -> Void
    typealias UtilityPrepaymentFlowEffectHandle = (Effect.UtilityPrepaymentFlowEffect, @escaping UtilityPrepaymentFlowDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent
    typealias Effect = UtilityPaymentFlowEffect
}
