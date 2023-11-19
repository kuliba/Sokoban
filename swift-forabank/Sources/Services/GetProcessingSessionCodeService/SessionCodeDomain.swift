//
//  SessionCodeDomain.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

/// A namespace.
public enum SessionCodeDomain {}

public extension SessionCodeDomain {
    
    typealias Payload = GetProcessingSessionCode
    typealias Result = Swift.Result<Payload, Error>
    typealias Completion = (Result) -> Void
    
    typealias Response = Swift.Result<(Data, HTTPURLResponse), Swift.Error>
    typealias ResponseCompletion = (Response) -> Void
    typealias PerformRequest = (URLRequest, @escaping ResponseCompletion) -> Void
    typealias MapResponse = (Data, HTTPURLResponse) -> Result
    
    enum Error: Swift.Error, Equatable {
        
        case connectivity
        case invalidData(statusCode: Int)
        case unknownStatusCode(Int)
        case serverError(statusCode: Int, errorMessage: String)
    }
}

extension SessionCodeDomain {
    
    public struct GetProcessingSessionCode: Equatable {
        
        public let code: String
        public let phone: String
        
        public init(code: String, phone: String) {
            self.code = code
            self.phone = phone
        }
    }
}
