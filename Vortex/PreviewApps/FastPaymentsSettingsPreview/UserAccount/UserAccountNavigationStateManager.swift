//
//  UserAccountNavigationStateManager.swift
//
//
//  Created by Igor Malyarov on 29.01.2024.
//

import FastPaymentsSettings
import UserAccountNavigationComponent

public struct UserAccountNavigationStateManager {
    
    public let reduce: Reduce
    public let handleOTPEffect: HandleOTPEffect
    public let makeFastPaymentsSettingsViewModel: MakeFastPaymentsSettingsViewModel
    
    public init(
        reduce: @escaping Reduce,
        handleOTPEffect: @escaping HandleOTPEffect,
        makeFastPaymentsSettingsViewModel: @escaping MakeFastPaymentsSettingsViewModel
    ) {
        self.reduce = reduce
        self.handleOTPEffect = handleOTPEffect
        self.makeFastPaymentsSettingsViewModel = makeFastPaymentsSettingsViewModel
    }
}

// MARK: - Types

public extension UserAccountNavigationStateManager {
    
    typealias State = UserAccountNavigation.State
    typealias Event = UserAccountNavigation.Event
    typealias Effect = UserAccountNavigation.Effect
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    
    typealias OTPDispatch = (Event.OTP) -> Void
    typealias HandleOTPEffect = (Effect.OTP, @escaping OTPDispatch) -> Void
    
    typealias MakeFastPaymentsSettingsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
}
