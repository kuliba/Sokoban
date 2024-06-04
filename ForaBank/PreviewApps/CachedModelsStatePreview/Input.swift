//
//  Input.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 04.06.2024.
//

import Foundation
import RxViewModel

typealias InputViewModel = RxViewModel<InputState, InputEvent, InputEffect>

struct InputState: Equatable {
    
    var text: String
}

enum InputEvent: Equatable {
    
    case setTo(String)
    case typed(String)
}

enum InputEffect: Equatable {
    
    case debounce(String)
}

final class InputReducer {}

extension InputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .setTo(text):
            state.text = text
            
        case let .typed(text):
            effect = .debounce(text)
        }
        
        return (state, effect)
    }
}

extension InputReducer {
    
    typealias State = InputState
    typealias Event = InputEvent
    typealias Effect = InputEffect
}

final class InputEffectHandler {}

extension InputEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .debounce(text):
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.3
            ) {
                dispatch(.setTo(text))
            }
        }
    }
}

extension InputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = InputEvent
    typealias Effect = InputEffect
}
