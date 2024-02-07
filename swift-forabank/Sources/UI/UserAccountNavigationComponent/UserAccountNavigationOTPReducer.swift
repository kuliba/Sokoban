//
//  UserAccountNavigationOTPReducer.swift
//
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent

public final class UserAccountNavigationOTPReducer {
    
    public init() {}
}

public extension UserAccountNavigationOTPReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .create(route):
            state.destination?.destination = .confirmSetBankDefault(route.viewModel, route.cancellable)
            
        case let .otpInput(otpInput):
            (state, effect) = reduce(state, otpInput)
            
        case .prepareSetBankDefault:
            (state, effect) = prepareSetBankDefault(state)
            
        case let .prepareSetBankDefaultResponse(response):
            (state, effect) = update(state, with: response)
        }
        
        return (state, effect)
    }
}

public extension UserAccountNavigationOTPReducer {
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    
    typealias State = UserAccountNavigation.State
    typealias Event = UserAccountNavigation.Event.OTP
    typealias Effect = UserAccountNavigation.Effect
}

private extension UserAccountNavigationOTPReducer {
    
    func reduce(
        _ state: State,
        _ otpInput: OTPInputStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch otpInput {
        case let .failure(failure):
            (state, effect) = reduce(state, failure)
            
        case .inflight:
            state.isLoading = true
            
        case .validOTP:
            state.isLoading = false
            effect = .fps(.bankDefault(.setBankDefaultResult(.success)))
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ failure: OTPInputComponent.ServiceFailure
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        state.destination?.destination = nil
        switch failure {
        case .connectivityError:
            effect = .fps(.bankDefault(.setBankDefaultResult(.serviceFailure(.connectivityError))))
            
        case let .serverError(message):
            let tryAgain = "Введен некорректный код. Попробуйте еще раз"
            if message == tryAgain {
                effect = .fps(.bankDefault(.setBankDefaultResult(.incorrectOTP(tryAgain))))
                
            } else {
                effect = .fps(.bankDefault(.setBankDefaultResult(.serviceFailure(.serverError(message)))))
            }
        }
        
        return (state, effect)
    }
    
    func prepareSetBankDefault(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
#warning("fpsAlert is not nil here; to nullify it `effect = .fps(.resetStatus)` is needed - but current implementation does not allow multiple effects - should `Effect?` be changed to `[Effect]` ??")
        if state.destination != nil,
           state.destination?.destination == nil {
            
            state.isLoading = true
            effect = .otp(.prepareSetBankDefault)
        }
        
        return (state, effect)
    }
    
    func update(
        _ state: State,
        with response: Event.PrepareSetBankDefaultResponse
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        effect = .fps(.resetStatus)
        
        switch response {
        case .success:
            effect = .otp(.create)
            
        case .connectivityError:
            state.destination?.destination = nil
            state.informer = "Ошибка изменения настроек СБП.\nПопробуйте позже."
            effect = .dismissInformer
            
        case let .serverError(message):
            state.destination?.destination = nil
            state.destination?.alert = .error(message: message, event: .closeAlert)
        }
        
        return (state, effect)
    }
}
