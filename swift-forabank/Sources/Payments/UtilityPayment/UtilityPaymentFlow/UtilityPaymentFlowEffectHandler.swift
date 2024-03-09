//
//  UtilityPaymentFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

public final class UtilityPaymentFlowEffectHandler<LastPayment, Operator>
where Operator: Identifiable {
    
    private let ppoHandleEffect: PPOHandleEffect
    
    public init(
        ppoHandleEffect: @escaping PPOHandleEffect
    ) {
        self.ppoHandleEffect = ppoHandleEffect
    }
}

public extension UtilityPaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .prePaymentOptions(prePaymentOptionsEffect):
            ppoHandleEffect(prePaymentOptionsEffect) { 
                
                dispatch(.prePaymentOptions($0))
            }
            
        case let .prePayment(prePaymentEffect):
            fatalError("can't handle prePaymentEffect \(prePaymentEffect)")
        }
    }
}

public extension UtilityPaymentFlowEffectHandler {
    
    typealias PPOEvent = PrePaymentOptionsEvent<LastPayment, Operator>
    typealias PPOEffect = PrePaymentOptionsEffect<Operator>
    typealias PPODispatch = (PPOEvent) -> Void
    typealias PPOHandleEffect = (PPOEffect, @escaping PPODispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator>
    typealias Effect = UtilityPaymentFlowEffect<Operator>
}
