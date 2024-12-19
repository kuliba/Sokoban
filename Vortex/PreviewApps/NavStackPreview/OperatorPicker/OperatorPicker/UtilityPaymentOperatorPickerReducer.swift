//
//  UtilityPaymentOperatorPickerReducer.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

final class UtilityPaymentOperatorPickerReducer<Icon> {}

extension UtilityPaymentOperatorPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
//        switch event {
//            
//        }
        
        return (state, effect)
    }
}

extension UtilityPaymentOperatorPickerReducer {
    
    typealias State = UtilityPaymentOperatorPickerState<Icon>
    typealias Event = UtilityPaymentOperatorPickerEvent<Icon>
    typealias Effect = UtilityPaymentOperatorPickerEffect
}
