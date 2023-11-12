//
//  GetProcessingSessionCodeService.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

/// Step 1.1 `getCode`
public final class GetProcessingSessionCodeService {
    
    public typealias ProcessResult = Swift.Result<Response, APIError>
    public typealias ProcessCompletion = (ProcessResult) -> Void
    public typealias Process = (@escaping ProcessCompletion) -> Void
    
    private let process: Process
    
    public init(process: @escaping Process) {
        
        self.process = process
    }
}

public extension GetProcessingSessionCodeService {
    
    typealias Result = Swift.Result<Response, Error>
    typealias Completion = (Result) -> Void
    
    func getCode(
        completion: @escaping Completion
    ) {
        process { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError(Error.init))
        }
    }
    
    enum Error: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
    }
}

extension GetProcessingSessionCodeService {
    
    public enum APIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
    }
    
    public struct Response {
        
        public let code: String
        public let phone: String
        
        public init(
            code: String,
            phone: String
        ) {
            self.code = code
            self.phone = phone
        }
    }
}

// MARK: - Error Mapping

private extension GetProcessingSessionCodeService.Error {
    
    init(_ error: GetProcessingSessionCodeService.APIError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}
