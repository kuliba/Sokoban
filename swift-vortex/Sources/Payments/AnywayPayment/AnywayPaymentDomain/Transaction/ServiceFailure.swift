//
//  ServiceFailure.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public enum ServiceFailure: Error, Equatable {
    
    case connectivityError(String)
    case serverError(String)
}

extension ServiceFailure {
    
    public var message: String {
        
        switch self {
        case let .connectivityError(message):
            return message
        case let .serverError(message):
            return message
        }
    }
}
