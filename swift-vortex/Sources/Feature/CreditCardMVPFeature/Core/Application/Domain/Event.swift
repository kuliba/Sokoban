//
//  Event.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

public enum Event<ApplicationSuccess> {
    
    case applicationResult(ApplicationResult)
    case loadedOTP(LoadedOTPResult)
    case `continue`
}

public extension Event {
    
    typealias ApplicationResult = Result<ApplicationSuccess, LoadFailure<ApplicationFailure>>
    
    typealias LoadedOTPResult = Result<LoadedOTP, LoadFailure<LoadOTPFailure>>
    
    struct LoadedOTP: Equatable {}
    
    enum ApplicationFailure {
        
        case alert, informer, otp
    }

    enum LoadOTPFailure {
        
        case alert, informer
    }
}

extension Event: Equatable where ApplicationSuccess: Equatable {}
