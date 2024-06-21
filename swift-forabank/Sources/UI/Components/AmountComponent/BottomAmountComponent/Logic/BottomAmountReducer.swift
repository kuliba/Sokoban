//
//  BottomAmountReducer.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

final class BottomAmountReducer {}

extension BottomAmountReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .button(buttonEvent):
            switch buttonEvent {
            case let .setActive(isEnabled):
                state.button.isEnabled = isEnabled
                
            case .tap:
                if state.button.isEnabled {
                    state.status = .tapped
                }
            }
            
        case let .edit(amount):
            state.value = amount
        }
        
        return (state, effect)
    }
}

extension BottomAmountReducer {
    
    typealias State = BottomAmount
    typealias Event = BottomAmountEvent
    typealias Effect = Never
}
