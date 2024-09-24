//
//  SegmentedPaymentProviderPickerEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

final class SegmentedPaymentProviderPickerEffectHandler<Operator> {}

extension SegmentedPaymentProviderPickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension SegmentedPaymentProviderPickerEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SegmentedPaymentProviderPickerEvent<Operator>
    typealias Effect = SegmentedPaymentProviderPickerEffect
}
