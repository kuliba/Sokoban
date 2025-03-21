//
//  Event.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

public enum Event<ApplicationSuccess> {
    
    case applicationResult(ApplicationResult)
    case `continue`
}

public extension Event {
    
    typealias ApplicationResult = Result<ApplicationSuccess, ApplicationFailure>
    typealias ApplicationFailure = LoadFailure<FailureType>
    
    enum FailureType {
        
        case alert, informer, otp
    }
}

extension Event: Equatable where ApplicationSuccess: Equatable {}
