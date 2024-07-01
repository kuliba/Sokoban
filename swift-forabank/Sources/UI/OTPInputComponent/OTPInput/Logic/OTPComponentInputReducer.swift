//
//  OTPComponentInputReducer.swift
//
//
//  Created by Igor Malyarov on 26.06.2024.
//

/// based on `OTPInputReducer` but does not replay failures up the chain
public final class OTPComponentInputReducer {
    
    private let countdownReduce: CountdownReduce
    private let otpFieldReduce: OTPFieldReduce
    
    public init(
        countdownReduce: @escaping CountdownReduce,
        otpFieldReduce: @escaping OTPFieldReduce
    ) {
        self.countdownReduce = countdownReduce
        self.otpFieldReduce = otpFieldReduce
    }
}

public extension OTPComponentInputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .countdown(countdownEvent):
            (state, effect) = reduce(state, with: countdownEvent)
            
        case let .otpField(otpFieldEvent):
            (state, effect) = reduce(state, with: otpFieldEvent)
        }
        
        return (state, effect)
    }
}

public extension OTPComponentInputReducer {
    
    typealias CountdownReduce = (CountdownState, CountdownEvent) -> (CountdownState, CountdownEffect?)
    typealias OTPFieldReduce = (OTPFieldState, OTPFieldEvent) -> (OTPFieldState, OTPFieldEffect?)
}

public extension OTPComponentInputReducer {
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}

private extension OTPComponentInputReducer {
    
    func reduce(
        _ state: State,
        with countdownEvent: CountdownEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.status {
        case .failure, .validOTP:
            break

        case var .input(input):
            let (countdownState, countdownEffect) = countdownReduce(input.countdown, countdownEvent)
            
            input.countdown = countdownState
            state.status = .input(input)
            effect = countdownEffect.map(Effect.countdown)
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        with otpFieldEvent: OTPFieldEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.status {
        case .failure, .validOTP:
            break
            
        case var .input(input):
            let (otpFieldState, otpFieldEffect) = otpFieldReduce(input.otpField, otpFieldEvent)
        
            input.otpField = otpFieldState
            state.status = .input(input)
            effect = otpFieldEffect.map(Effect.otpField)
        }
        
        return (state, effect)
    }
}
