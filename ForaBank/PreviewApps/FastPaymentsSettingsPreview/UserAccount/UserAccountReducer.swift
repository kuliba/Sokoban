//
//  UserAccountReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings
import UIPrimitives

final class UserAccountReducer {
    
    private let demoReduce: DemoReduce
    private let otpReduce: OTPReduce
    private let factory: Factory
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
        demoReduce: @escaping DemoReduce,
        otpReduce: @escaping OTPReduce,
        factory: Factory,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.demoReduce = demoReduce
        self.otpReduce = otpReduce
        self.factory = factory
        self.scheduler = scheduler
    }
}

extension UserAccountReducer {
    
    /// `dispatch` is used in `sink`
    func reduce(
        _ state: State,
        _ event: Event,
        _ inform: @escaping Inform,
        _ dispatch: @escaping Dispatch
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .closeAlert:
            state.alert = nil
            effect = .fps(.resetStatus)
            
        case .closeFPSAlert:
            state.alert = nil
            effect = .fps(.resetStatus)
            
        case .dismissFPSDestination:
            state.fpsDestination = nil
            
        case .dismissDestination:
            state.destination = nil
            
        case .dismissRoute:
            state = .init()
            
        case let .demo(demoEvent):
            let (demoState, demoEffect) = demoReduce(state, demoEvent, inform)
            state = demoState
            effect = demoEffect.map(Effect.demo)
            
        case let .fps(.updated(fpsState)):
            state = reduce(state, with: fpsState, inform: inform)
            
        case let .otp(otp):
            (state, effect) = otpReduce(state, otp, inform) { dispatch(.otp($0)) }
        }
        
        return (state, effect)
    }
}

extension UserAccountReducer {
    
    typealias Inform = (String) -> Void
    
    typealias DemoReduce = (State, Event.Demo, @escaping Inform) -> (State, Effect.Demo?)
    
    typealias OTPDispatch = (Event.OTP) -> Void
    typealias OTPReduce = (State, Event.OTP, @escaping Inform, @escaping OTPDispatch) -> (State, Effect?)

    typealias Dispatch = (Event) -> Void
    
    typealias State = UserAccountViewModel.State
    typealias Event = UserAccountViewModel.Event
    typealias Effect = UserAccountViewModel.Effect
}

private extension UserAccountReducer {
    
    // MARK: - Fast Payments Settings domain
    
    func reduce(
        _ state: State,
        with settings: FastPaymentsSettingsState,
        inform: @escaping (String) -> Void
    ) -> State {
        
        var state = state
        
        switch (settings.settingsResult, settings.status) {
        case (_, .inflight):
            state.isLoading = true
            
        case (nil, _):
            break
            
        case let (.success(.contracted(contracted)), nil):
            state.isLoading = false
            let message = contracted.bankDefaultResponse.requestLimitMessage
            state.alert = message.map { .fpsAlert(.error(
                message: $0,
                event: .closeAlert
            )) }
            
        case (.success(.missingContract), nil):
            state.isLoading = false
            state.alert = .fpsAlert(.missingContract(event: .closeAlert))
            
        case let (.success, .some(status)):
            state = update(state, with: status, inform)
            
        case let (.failure(failure), _):
            // final => dismissRoute
            switch failure {
            case let .serverError(message):
                state.isLoading = false
                state.alert = .fpsAlert(.error(
                    message: message,
                    event: .dismissRoute
                ))
                
            case .connectivityError:
                state.isLoading = false
                state.alert = .fpsAlert(.tryAgainFPSAlert(.dismissRoute))
            }
        }
        
        return state
    }
    
    func update(
        _ state: State,
        with status: FastPaymentsSettingsState.Status,
        _ inform: @escaping Inform
    ) -> State {
        
        var state = state
        
        switch status {
        case .inflight:
            state.isLoading = true
            
        case let .getC2BSubResponse(getC2BSubResponse):
            state.isLoading = false
            state.fpsDestination = .c2BSub(getC2BSubResponse, nil)
            
        case .connectivityError:
            state.isLoading = false
            // non-final => closeAlert
            state.alert = .fpsAlert(.tryAgainFPSAlert(.closeAlert))
            
        case let .serverError(message):
            state.isLoading = false
            // non-final => closeAlert
            state.alert = .fpsAlert(.ok(
                message: message,
                event: .closeAlert
            ))
            
        case .missingProduct:
            state.isLoading = false
            state.alert = .fpsAlert(.missingProduct(event: .dismissRoute))
            
        case .confirmSetBankDefault:
            // state.fpsDestination = .confirmSetBankDefault
            // effect = .fps(.resetStatus)
            fatalError("what should happen here?")
            
        case .setBankDefault:
            state.alert = .fpsAlert(.setBankDefault(
                primaryEvent: .otp(.prepareSetBankDefault),
                secondaryEvent: .closeAlert
            ))
            
        case .setBankDefaultSuccess:
            state.isLoading = false
            inform("Банк по умолчанию установлен.")
            
        case .updateContractFailure:
            state.isLoading = false
            inform("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            state = .init()
        }
        
        return state
    }
}
