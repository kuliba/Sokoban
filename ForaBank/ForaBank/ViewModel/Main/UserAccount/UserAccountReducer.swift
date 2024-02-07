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
        _ event: Event,
        _ otpDispatch: @escaping OTPDispatch
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
            (state, effect) = otpReduce(
                state,
                otpEvent,
                otpDispatch
            )
            
        case let .route(routeEvent):
            state = routeEventReduce(state, routeEvent)
        }
        
        return (state, effect)
    }
}

extension UserAccountReducer {
    
    typealias AlertReduce = (UserAccountRoute, UserAccountEvent.AlertButtonTap) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias FPSReduce = (UserAccountRoute, UserAccountEvent.FastPaymentsSettings) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias OTPDispatch = (UserAccountEvent.OTP) -> Void
    typealias OTPReduce = (UserAccountRoute, UserAccountEvent.OTP, @escaping OTPDispatch) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias RouteEventReduce = (UserAccountRoute, UserAccountEvent.RouteEvent) -> UserAccountRoute
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent
    typealias Effect = UserAccountEffect
}
