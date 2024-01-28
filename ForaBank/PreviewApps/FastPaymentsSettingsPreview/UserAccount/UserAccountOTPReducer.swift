//
//  UserAccountOTPReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent

final class UserAccountOTPReducer {
    
    private let makeTimedOTPInputViewModel: MakeTimedOTPInputViewModel
    private let scheduler: AnySchedulerOfDispatchQueue

    init(
        makeTimedOTPInputViewModel: @escaping MakeTimedOTPInputViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.makeTimedOTPInputViewModel = makeTimedOTPInputViewModel
        self.scheduler = scheduler
    }
}

extension UserAccountOTPReducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ inform: @escaping Inform,
        _ dispatch: @escaping Dispatch
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .otpInput(otpInput):            
            switch otpInput {
            case let .failure(failure):
            #warning("extract to helper")
                state.isLoading = false
                state.fpsRoute?.destination = nil
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
                
            case .inflight:
                state.isLoading = true
                
            case .validOTP:
                state.isLoading = false
                effect = .fps(.bankDefault(.setBankDefaultResult(.success)))
            }
            
        case .prepareSetBankDefault:
            #warning("extract to helper")
            #warning("fpsAlert is not nil here; to nullify it `effect = .fps(.resetStatus)` is needed - but current implementation does not allow multiple effects - should `Effect?` be changed to `[Effect]` ??")
            guard state.fpsRoute != nil,
                  state.fpsRoute?.destination == nil
                  // state.fpsRoute?.alert == nil
            else { break }
            
            state.isLoading = true
            effect = .otp(.prepareSetBankDefault)
            
        case let .prepareSetBankDefaultResponse(response):
            (state, effect) = update(state, with: response, inform, dispatch)
        }
        
        return (state, effect)
    }
    
    func update(
        _ state: State,
        with response: Event.PrepareSetBankDefaultResponse,
        _ inform: @escaping Inform,
        _ dispatch: @escaping Dispatch
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        effect = .fps(.resetStatus)
        
        switch response {
        case .success:
            let otpInputViewModel = makeTimedOTPInputViewModel(scheduler)
            let cancellable = otpInputViewModel.$state
                .compactMap(\.projection)
                .removeDuplicates()
                .map(Event.otpInput)
                .receive(on: scheduler)
                .sink { dispatch($0) }
            
            state.fpsRoute?.destination = .confirmSetBankDefault(otpInputViewModel, cancellable)
            
        case .connectivityError:
            state.fpsRoute?.destination = nil
            inform("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            
        case let .serverError(message):
            state.fpsRoute?.destination = nil
            state.fpsRoute?.alert = .error(message: message, event: .closeAlert)
        }
        
        return (state, effect)
    }
}

extension UserAccountOTPReducer {
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    
    typealias MakeTimedOTPInputViewModel = (AnySchedulerOfDispatchQueue) -> TimedOTPInputViewModel
    
    typealias State = UserAccountViewModel.State
    typealias Event = UserAccountViewModel.Event.OTP
    typealias Effect = UserAccountViewModel.Effect
}

// MARK: - OTP for Fast Payments Settings

private extension OTPInputState {
    
    var projection: OTPInputStateProjection? {
        
        switch self {
        case let .failure(otpFieldFailure):
            switch otpFieldFailure {
            case .connectivityError:
                return .failure(.connectivityError)
                
            case let .serverError(message):
                return .failure(.serverError(message))
            }
            
        case let .input(input):
            guard input.otpField.status == .inflight 
            else { return nil }
            
            return .inflight
            
        case .validOTP:
            return .validOTP
        }
    }
}
