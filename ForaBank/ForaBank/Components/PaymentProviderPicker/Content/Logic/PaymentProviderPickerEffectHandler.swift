//
//  PaymentProviderPickerEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

final class PaymentProviderPickerEffectHandler<Operator> {}

extension PaymentProviderPickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension PaymentProviderPickerEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentProviderPickerEvent<Operator>
    typealias Effect = PaymentProviderPickerEffect
}
