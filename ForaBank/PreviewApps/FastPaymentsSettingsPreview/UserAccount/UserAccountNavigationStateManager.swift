//
//  UserAccountNavigationStateManager.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 29.01.2024.
//

import UserAccountNavigationComponent

struct UserAccountNavigationStateManager {
    
    let reduce: Reduce
    let handleOTPEffect: HandleOTPEffect
    let makeFastPaymentsSettingsViewModel: MakeFastPaymentsSettingsViewModel
}

// MARK: - Types

extension UserAccountNavigationStateManager {
    
    typealias State = UserAccountNavigation.State
    typealias Event = UserAccountNavigation.Event
    typealias Effect = UserAccountNavigation.Effect
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    
    typealias Reduce = (State, Event, @escaping Inform, @escaping Dispatch) -> (State, Effect?)
    
    typealias OTPDispatch = (Event.OTP) -> Void
    typealias HandleOTPEffect = (Effect.OTP, @escaping OTPDispatch) -> Void
    
    typealias MakeFastPaymentsSettingsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
}
