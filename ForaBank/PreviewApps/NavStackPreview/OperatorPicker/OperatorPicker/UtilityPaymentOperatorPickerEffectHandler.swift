//
//  UtilityPaymentOperatorPickerEffectHandler.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

final class UtilityPaymentOperatorPickerEffectHandler<Icon> {}

extension UtilityPaymentOperatorPickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension UtilityPaymentOperatorPickerEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentOperatorPickerEvent<Icon>
    typealias Effect = UtilityPaymentOperatorPickerEffect
}
