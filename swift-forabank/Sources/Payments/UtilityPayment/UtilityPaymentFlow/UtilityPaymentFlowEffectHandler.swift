//
//  UtilityPaymentFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

public final class UtilityPaymentFlowEffectHandler<LastPayment, Operator, Response, Service>
where Operator: Identifiable {
    
    private let ppoHandleEffect: PPOHandleEffect
    private let ppHandleEffect: PPHandleEffect
    
    public init(
        ppoHandleEffect: @escaping PPOHandleEffect,
        ppHandleEffect: @escaping PPHandleEffect
    ) {
        self.ppoHandleEffect = ppoHandleEffect
        self.ppHandleEffect = ppHandleEffect
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
            ppHandleEffect(prePaymentEffect) {
                
                dispatch(.prePayment($0))
            }
        }
    }
}

public extension UtilityPaymentFlowEffectHandler {
    
    typealias PPOEvent = PrePaymentOptionsEvent<LastPayment, Operator>
    typealias PPOEffect = PrePaymentOptionsEffect<Operator>
    typealias PPODispatch = (PPOEvent) -> Void
    typealias PPOHandleEffect = (PPOEffect, @escaping PPODispatch) -> Void
    
    typealias PPEvent = PrePaymentEvent<LastPayment, Operator, Response, Service>
    typealias PPEffect = PrePaymentEffect<LastPayment, Operator, Service>
    typealias PPDispatch = (PPEvent) -> Void
    typealias PPHandleEffect = (PPEffect, @escaping PPDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Response, Service>
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, Service>
}
