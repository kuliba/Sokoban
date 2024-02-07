//
//  UserAccountNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.02.2024.
//

import FastPaymentsSettings
import UserAccountNavigationComponent

struct UserAccountNavigationStateManager {
    
    let userAccountReduce: UserAccountReduce
    let handleModelEffect: HandleModelEffect
    let handleOTPEffect: HandleOTPEffect
}

extension UserAccountNavigationStateManager {
    
    typealias UserAccountReduce = (UserAccountRoute, UserAccountEvent) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias Dispatch = (UserAccountEvent) -> Void
    typealias HandleModelEffect = (UserAccountEffect.ModelEffect, @escaping Dispatch) -> Void
    
    typealias OTPDispatch = (UserAccountEvent.OTP) -> Void
    typealias HandleOTPEffect = (UserAccountNavigation.Effect.OTP, @escaping OTPDispatch) -> Void
}
