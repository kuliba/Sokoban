//
//  LoadFailure.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

public struct LoadFailure<FailureType>: Error {
    
    public let message: String
    public let type: FailureType
    
    public init(
        message: String,
        type: FailureType
    ) {
        self.message = message
        self.type = type
    }
}

extension LoadFailure: Equatable where FailureType: Equatable {}
