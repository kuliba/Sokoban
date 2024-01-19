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
        case let .edit(text):
            (state, effect) = edit(state, with: text)
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
    
    func edit(
        _ state: State,
        with text: String
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?

        if state.text.count == length - 1,
           text.count == length {
            
            effect = .submitOTP
        }
        
        print(text, "from `edit`")
        let text = text.filter(\.isNumber).prefix(length)
        print(text, "filtered")
        state.text = .init(text)
        print(state.text, "in state")
        
        return (state, effect)
    }
}
