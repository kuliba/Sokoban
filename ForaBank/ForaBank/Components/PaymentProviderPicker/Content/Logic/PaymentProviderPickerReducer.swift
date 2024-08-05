//
//  PaymentProviderPickerReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

final class PaymentProviderPickerReducer<Provider> {}

extension PaymentProviderPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(select):
            reduce(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

extension PaymentProviderPickerReducer {
    
    typealias State = PaymentProviderPickerState<Provider>
    typealias Event = PaymentProviderPickerEvent<Provider>
    typealias Effect = PaymentProviderPickerEffect
}

private extension PaymentProviderPickerReducer {
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select
    ) {
        switch select {
        case .addCompany:
            state.selection = .addCompany
            
        case let .item(item):
            state.selection = .item(item)
            
        case .payByInstructions:
            state.selection = .payByInstructions
        }
    }
}
