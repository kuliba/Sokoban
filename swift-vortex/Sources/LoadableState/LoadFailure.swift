//
//  LoadFailure.swift
//  
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import Foundation

public struct LoadFailure: Error, Equatable {
    
    public let message: String
    public let type: FailureType
    
    public init(
        message: String,
        type: FailureType
    ) {
        self.message = message
        self.type = type
    }
    
    public enum FailureType {
        
        case alert, informer, otp
    }
}
