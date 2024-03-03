//
//  PaymentsTransfersEffectHandler.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

final class PaymentsTransfersEffectHandler {
    
}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

extension PaymentsTransfersEffectHandler {

    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
