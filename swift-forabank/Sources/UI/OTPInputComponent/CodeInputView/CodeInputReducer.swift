//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 11.06.2024.
//

import Foundation


public final class CodeInputReducer {
    
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

public extension CodeInputReducer {
    
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

public extension CodeInputReducer {
    
    typealias State = CodeInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}

public extension CodeInputReducer {
    
    typealias CountdownReduce = (CountdownState, CountdownEvent) -> (CountdownState, CountdownEffect?)
    typealias OTPFieldReduce = (OTPFieldState, OTPFieldEvent) -> (OTPFieldState, OTPFieldEffect?)
}

private extension CodeInputReducer {
    
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
            
            switch countdownState {
            case let .failure(countdownFailure):
                switch countdownFailure {
                case .connectivityError:
                    state.status = .failure(.connectivityError)
                    
                case let .serverError(message):
                    state.status = .failure(.serverError(message))
                }
                effect = countdownEffect.map(Effect.countdown)
                
            default:
                input.countdown = countdownState
                state.status = .input(input)
                effect = countdownEffect.map(Effect.countdown)
            }
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
        
            switch otpFieldState.status {
            case let .failure(otpFieldFailure):
                state.status = .failure(otpFieldFailure)
                
            case .validOTP:
                state.status = .validOTP
                
            default:
                input.otpField = otpFieldState
                state.status = .input(input)
            }

            effect = otpFieldEffect.map(Effect.otpField)
        }
        
        return (state, effect)
    }
}
