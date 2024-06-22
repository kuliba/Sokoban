//
//  FooterReducer.swift
//  
//
//  Created by Igor Malyarov on 21.06.2024.
//

import Foundation

public final class FooterReducer {
    
    public init() {}
}

public extension FooterReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        let effect: Effect? = nil
        
        switch event {
        case let .button(event):
            reduce(&state, with: event)
            
        case let .edit(amount):
            reduce(&state, with: amount)
            
        case let .style(style):
            state.style = style
        }
        
        return (state, effect)
    }
}

public extension FooterReducer {
    
    typealias State = FooterState
    typealias Event = FooterEvent
    typealias Effect = FooterEffect
}

private extension FooterReducer {
    
    func reduce(
        _ state: inout State,
        with event: Event.ButtonEvent
    ) {
        switch event {
        case .disable:
            switch state.buttonState {
            case .active:
                state.buttonState = .inactive
                
            case .inactive, .tapped:
                break
            }
            
        case .enable:
            state.buttonState = .active
            
        case .tap:
            switch state.buttonState {
            case .active:
                state.buttonState = .tapped
            
            case .inactive, .tapped:
                break
            }
        }
    }
    
    func reduce(
        _ state: inout State,
        with amount: Decimal
    ) {
        guard amount >= .zero else { return }
        
        switch state.buttonState {
        case .active:
            state.amount = amount
            
        case .inactive, .tapped:
            break
        }
    }
}
