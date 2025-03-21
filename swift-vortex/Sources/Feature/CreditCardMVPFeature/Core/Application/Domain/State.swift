//
//  State.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

import StateMachines

public struct State<ApplicationSuccess, OTP> {
    
    public var applicationResult: ApplicationResult?
    public var otp: OTPState = .pending
    
    public init(
        applicationResult: ApplicationResult? = nil,
        otp: OTPState
    ) {
        self.applicationResult = applicationResult
        self.otp = otp
    }
}

public extension State {
    
    typealias ApplicationResult = Result<ApplicationSuccess, Failure>
    
    typealias Failure = LoadFailure<FailureType>
    
    enum FailureType {
        
        case alert, informer
    }
    
    typealias OTPState = LoadState<OTP, Failure>
}

extension State: Equatable where ApplicationSuccess: Equatable, OTP: Equatable {}
