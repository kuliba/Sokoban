//
//  UserAccountNavigationReducer.swift
//
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings
import UIPrimitives

public final class UserAccountNavigationReducer {
    
    private let fpsReduce: FPSReduce
    private let otpReduce: OTPReduce
    private let scheduler: AnySchedulerOfDispatchQueue
    
    public init(
        fpsReduce: @escaping FPSReduce,
        otpReduce: @escaping OTPReduce,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.fpsReduce = fpsReduce
        self.otpReduce = otpReduce
        self.scheduler = scheduler
    }
}

public extension UserAccountNavigationReducer {
    
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
           // effect = .fps(.resetStatus)
            
        case .closeFPSAlert:
           // state.alert = nil
            // state.fpsRoute?.alert = nil
            effect = .fps(.resetStatus)
            
        case .dismissFPSDestination:
            state.fpsRoute?.destination = nil
            effect = .fps(.resetStatus)
            
        case .dismissDestination:
            state.destination = nil
            effect = .fps(.resetStatus)
            
        case .dismissRoute:
            state = .init()
            
        case let .fps(.updated(fpsState)):
            (state, effect) = fpsReduce(state, fpsState, inform)
            
        case let .otp(otpEvent):
            (state, effect) = otpReduce(state, otpEvent, inform) { dispatch(.otp($0)) }
        }
        
        return (state, effect)
    }
}

public extension UserAccountNavigationReducer {
    
    typealias Inform = (String) -> Void
    
    typealias FPSReduce = (State, FastPaymentsSettingsState, @escaping Inform) -> (State, Effect?)
    
    typealias OTPDispatch = (Event.OTP) -> Void
    typealias OTPReduce = (State, Event.OTP, @escaping Inform, @escaping OTPDispatch) -> (State, Effect?)

    typealias Dispatch = (Event) -> Void
    
    typealias State = UserAccountNavigation.State
    typealias Event = UserAccountNavigation.Event
    typealias Effect = UserAccountNavigation.Effect
}
