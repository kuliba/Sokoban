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
#warning("move nullification to reducer where fps state is reduced")
            state.fpsRoute?.destination = nil
            
            switch otpInput {
            case let .failure(failure):
                switch failure {
                case .connectivityError:
                    effect = .fps(.bankDefault(.setBankDefaultPrepared(.connectivityError)))
                    
                case let .serverError(message):
                    let tryAgain = "Введен некорректный код. Попробуйте еще раз"
                    if message == tryAgain {
                        inform(message)
                    } else {
                        effect = .fps(.bankDefault(.setBankDefaultPrepared(.serverError(message))))
                    }
                }
                
            case .validOTP:
                effect = .fps(.bankDefault(.setBankDefaultPrepared(nil)))
            }
            
        case .prepareSetBankDefault:
            state.alert = nil
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
            
        case .input:
            return nil
            
        case .validOTP:
            return .validOTP
        }
    }
}
