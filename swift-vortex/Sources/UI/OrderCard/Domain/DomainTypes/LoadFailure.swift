//
//  LoadFailure.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

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
        
        case alert, informer
    }
}
