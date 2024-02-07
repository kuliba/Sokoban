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
        case .closeAlert:
            state.alert = nil
            effect = .navigation(.fps(.resetStatus))
            
        case .closeFPSAlert:
            effect = .navigation(.fps(.resetStatus))
            
        case .dismissFPSDestination:
            // state.fpsDestination = nil
            effect = .navigation(.fps(.resetStatus))
            
        case .dismissDestination:
            state.link = nil
            effect = .navigation(.fps(.resetStatus))
            
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
