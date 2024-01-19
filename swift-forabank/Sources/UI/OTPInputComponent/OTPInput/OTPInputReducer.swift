//
//  OTPInputReducer.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class OTPInputReducer {
    
    private let length: Int
    
    public init(length: Int = 6) {
        
        self.length = length
    }
}

public extension OTPInputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .confirmOTP:
            (state, effect) = confirm(state)
            
        case let .edit(text):
            state = edit(state, with: text)
        }
        
        return (state, effect)
    }
}

public extension OTPInputReducer {
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}

private extension OTPInputReducer {
    
    func confirm(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        if state.isInputComplete {
            
            state.status = .inflight
            effect = .submitOTP(state.text)
        }
        
        return (state, effect)
    }

    func edit(
        _ state: State,
        with text: String
    ) -> State {
        
        let text = text.filter(\.isNumber).prefix(length)
        
        return state.updated(
            text: .init(text),
            isInputComplete: text.count >= length
        )
    }
}
