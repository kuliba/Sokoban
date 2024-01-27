//
//  UserAccountOTPReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings

final class UserAccountOTPReducer {
    
    private let factory: Factory
    private let scheduler: AnySchedulerOfDispatchQueue

    init(
        factory: Factory,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.factory = factory
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
            state.fpsDestination = nil
            
            switch otpInput {
            case let .failure(failure):
                switch failure {
                case .connectivityError:
                    effect = .fps(.bankDefault(.setBankDefaultPrepared(.connectivityError)))
                    
#warning("should handle with informer not alert `serverError` with message Введен некорректный код. Попробуйте еще раз")
                case let .serverError(message):
                    effect = .fps(.bankDefault(.setBankDefaultPrepared(.serverError(message))))
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
            let otpInputViewModel = factory.makeTimedOTPInputViewModel(scheduler)
            let cancellable = otpInputViewModel.$state
                .compactMap(\.projection)
                .removeDuplicates()
                .map(Event.otpInput)
                .receive(on: scheduler)
                .sink { dispatch($0) }
            
            state.fpsDestination = .confirmSetBankDefault(otpInputViewModel, cancellable)
            
        case .connectivityError:
            state.fpsDestination = nil
            inform("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            
        case let .serverError(message):
            state.alert = .fpsAlert(.error(
                message: message,
                event: .closeAlert
            ))
        }
        
        return (state, effect)
    }
}

extension UserAccountOTPReducer {
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    
    typealias State = UserAccountViewModel.State
    typealias Event = UserAccountViewModel.Event.OTP
    typealias Effect = UserAccountViewModel.Effect
}
