//
//  GetProcessingSessionCodeDomain.swift
//  
//
//  Created by Igor Malyarov on 08.08.2023.
//

/// A namespace.
public enum GetProcessingSessionCodeDomain {}

public extension GetProcessingSessionCodeDomain {
    
    typealias Result = Swift.Result<SessionCode, Error>
    typealias Completion = (Result) -> Void
    typealias GetProcessingSessionCode = (@escaping Completion) -> Void
}
