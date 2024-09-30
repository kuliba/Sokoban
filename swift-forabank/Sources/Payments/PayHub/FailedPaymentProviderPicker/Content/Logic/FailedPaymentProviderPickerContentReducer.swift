//
//  FailedPaymentProviderPickerContentReducer.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

public final class FailedPaymentProviderPickerContentReducer {
    
    public init() {}
}

public extension FailedPaymentProviderPickerContentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .detailPay:
            state.selection = .detailPay
            
        case .resetSelection:
            state.selection = nil
        }
        
        return (state, effect)
    }
}

public extension FailedPaymentProviderPickerContentReducer {
    
    typealias State = FailedPaymentProviderPickerContentState
    typealias Event = FailedPaymentProviderPickerContentEvent
    typealias Effect = FailedPaymentProviderPickerContentEffect
}
