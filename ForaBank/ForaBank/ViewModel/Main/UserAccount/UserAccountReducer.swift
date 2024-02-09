//
//  UserAccountReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.02.2024.
//

import FastPaymentsSettings
import OTPInputComponent
import UserAccountNavigationComponent

final class UserAccountReducer {
    
    private let alertReduce: AlertReduce
    private let fpsReduce: FPSReduce
    private let otpReduce: OTPReduce
    private let routeEventReduce: RouteEventReduce
    
    init(
        alertReduce: @escaping AlertReduce,
        fpsReduce: @escaping FPSReduce,
        otpReduce: @escaping OTPReduce,
        routeEventReduce: @escaping RouteEventReduce
    ) {
        self.alertReduce = alertReduce
        self.fpsReduce = fpsReduce
        self.otpReduce = otpReduce
        self.routeEventReduce = routeEventReduce
    }
}

extension UserAccountReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
#warning("it looks like all `close` and `dismiss` events should be processed with events (effects??) to destinations; and the real dismiss should be encapsulated into state change in reaction to destination state change")
        case .closeAlert:
            state.alert = nil
            state.fpsViewModel?.event(.resetStatus)
            
        case .closeFPSAlert:
            state.fpsViewModel?.event(.resetStatus)
            
        case .dismissFPSDestination:
            // state.fpsDestination = nil
            if var fpsRoute = state.fpsRoute {
                fpsRoute.destination = nil
                state.link = .fastPaymentSettings(.new(fpsRoute))
            }
            state.fpsViewModel?.event(.resetStatus)
            
        case .dismissDestination:
            state.link = nil
            state.fpsViewModel?.event(.resetStatus)
            
        case .dismissInformer:
            state.informer = nil
            state.fpsViewModel?.event(.resetStatus)
            
        case .dismissRoute:
            state = .init()
            
        case let .alertButtonTapped(alertButtonTapped):
            (state, effect) = alertReduce(state, alertButtonTapped)
            
        case let .fps(fastPaymentsSettings):
            (state, effect) = fpsReduce(state, fastPaymentsSettings)
            
        case let .otp(otpEvent):
            (state, effect) = otpReduce(state, otpEvent)
            
        case let .route(routeEvent):
            state = routeEventReduce(state, routeEvent)
        }
        
        return (state, effect)
    }
}

extension UserAccountReducer {
    
    typealias AlertReduce = (State, Event.AlertButtonTap) -> (State, Effect?)
    typealias FPSReduce = (State, Event.FastPaymentsSettings) -> (State, Effect?)
    typealias OTPReduce = (State, Event.OTP) -> (State, Effect?)
    typealias RouteEventReduce = (State, Event.RouteEvent) -> State
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent
    typealias Effect = UserAccountEffect
}

private extension UserAccountReducer.State {
    
    var fpsViewModel: FastPaymentsSettingsViewModel? { fpsRoute?.viewModel }
}

private extension UserAccountReducer.State {
    
    var fpsRoute: UserAccountRoute.Link.FastPaymentSettings.FPSRoute? {
        
        guard case let .fastPaymentSettings(.new(fpsRoute)) = link
        else { return nil }
        
        return fpsRoute
    }
}
