//
//  UserAccountNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.02.2024.
//

import FastPaymentsSettings
import UserAccountNavigationComponent

struct UserAccountNavigationStateManager {
    
    let alertReduce: AlertReduce
    let fpsReduce: FPSReduce
    let otpReduce: OTPReduce
    let routeEventReduce: RouteEventReduce
    let handleModelEffect: HandleModelEffect
    let handleOTPEffect: HandleOTPEffect
}

extension UserAccountNavigationStateManager {
    
    typealias AlertReduce = (UserAccountRoute, UserAccountEvent.AlertButtonTap) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias FPSReduce = (UserAccountRoute, UserAccountEvent.FastPaymentsSettings) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias OTPDispatch = (UserAccountEvent.OTP) -> Void
    typealias OTPReduce = (UserAccountRoute, UserAccountEvent.OTP, @escaping OTPDispatch) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias RouteEventReduce = (UserAccountRoute, UserAccountEvent.RouteEvent) -> UserAccountRoute
    
    typealias Dispatch = (UserAccountEvent) -> Void
    typealias HandleModelEffect = (UserAccountEffect.ModelEffect, @escaping Dispatch) -> Void
    
    typealias HandleOTPEffect = (UserAccountNavigation.Effect.OTP, @escaping OTPDispatch) -> Void
}
