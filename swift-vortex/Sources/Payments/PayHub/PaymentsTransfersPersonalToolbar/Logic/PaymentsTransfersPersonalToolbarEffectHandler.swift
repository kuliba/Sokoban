//
//  PaymentsTransfersPersonalToolbarEffectHandler.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public final class PaymentsTransfersPersonalToolbarEffectHandler {
    
    public init() {}
}

public extension PaymentsTransfersPersonalToolbarEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        }
    }
}

public extension PaymentsTransfersPersonalToolbarEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersPersonalToolbarEvent
    typealias Effect = PaymentsTransfersPersonalToolbarEffect
}
