//
//  PaymentsTransfersEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

final class PaymentsTransfersEffectHandler {}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
