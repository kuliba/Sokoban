//
//  OTPFieldReducer.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class OTPFieldReducer {
    
    private let length: Int
    
    public init(length: Int = 6) {
        
        self.length = length
    }
}

public extension OTPFieldReducer {
    
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
            
        case let .failure(OTPFieldFailure):
            if state.isInputComplete {
                state = state.updated(
                    text: state.text,
                    isInputComplete: state.isInputComplete,
                    status: .failure(OTPFieldFailure)
                )
            }
            
        case .otpValidated:
            if state.isInputComplete {
                state = state.updated(
                    text: state.text,
                    isInputComplete: state.isInputComplete,
                    status: .validOTP
                )
            }
        }
        
        return (state, effect)
    }
}

public extension OTPFieldReducer {
    
    typealias State = OTPFieldState
    typealias Event = OTPFieldEvent
    typealias Effect = OTPFieldEffect
}

private extension OTPFieldReducer {
    
    func confirm(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        if state.isInputComplete && state.status != .inflight {
            
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
            isInputComplete: text.count >= length,
            status: nil
        )
    }
}
