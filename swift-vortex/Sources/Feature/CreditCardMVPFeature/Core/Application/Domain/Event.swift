//
//  Event.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

public enum Event<ApplicationSuccess, OTP> {
    
    case applicationResult(ApplicationResult)
    case `continue`
    case loadedOTP(LoadedOTPResult)
}

public extension Event {
    
    typealias ApplicationResult = Result<ApplicationSuccess, LoadFailure<ApplicationFailure>>
    
    typealias LoadedOTPResult = Result<OTP, LoadFailure<LoadOTPFailure>>
    
    enum ApplicationFailure {
        
        case alert, informer, otp
    }

    enum LoadOTPFailure {
        
        case alert, informer
    }
}

extension Event: Equatable where ApplicationSuccess: Equatable, OTP: Equatable {}
