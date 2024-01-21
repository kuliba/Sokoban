//
//  OTPInputReducer.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

public final class OTPInputReducer {
    
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

public extension OTPInputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .countdown(countdownEvent):
            let (countdownState, countdownEffect) = countdownReduce(state.countdown, countdownEvent)
            state.countdown = countdownState
            effect = countdownEffect.map(Effect.countdown)
            
        case let .otpField(otpFieldEvent):
            let (otpFieldState, otpFieldEffect) = otpFieldReduce(state.otpField, otpFieldEvent)
            state.otpField = otpFieldState
            effect = otpFieldEffect.map(Effect.otpField)
        }
        
        return (state, effect)
    }
}

public extension OTPInputReducer {
    
    typealias CountdownReduce = (CountdownState, CountdownEvent) -> (CountdownState, CountdownEffect?)
    typealias OTPFieldReduce = (OTPFieldState, OTPFieldEvent) -> (OTPFieldState, OTPFieldEffect?)
}

public extension OTPInputReducer {
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}
