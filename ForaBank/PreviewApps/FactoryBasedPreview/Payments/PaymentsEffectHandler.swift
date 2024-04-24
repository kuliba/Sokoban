//
//  PaymentsEffectHandler.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentsEffectHandler {}

extension PaymentsEffectHandler {
    
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

extension PaymentsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
}

private extension PaymentsEffectHandler {
    
    func initiateUtilityPayment() {
        
        fatalError()
    }
}
