//
//  ServerAgentError.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2023.
//

import Foundation

/// ServerAgent's error
public enum ServerAgentError: LocalizedError {
    
    case requestCreationError(Error)
    case sessionError(Error)
    case emptyResponse
    case emptyResponseData
    case unexpectedResponseStatus(Int)
    case corruptedData(Error)
    case serverStatus(ServerStatusCode, errorMessage: String?)
    case notAuthorized

    public var errorDescription: String? {
        
        switch self {
        case .requestCreationError(let error):
            return "Server: request creation failed with error: \(error.localizedDescription)"
            
        case .sessionError(let error):
            return "\(error.localizedDescription)"

        case .emptyResponse:
            return "Server: unexpected empty response"

        case .emptyResponseData:
            return "Server: unexpected empty response data"
            
        case .unexpectedResponseStatus(let statusCode):
            return "Server: unexpected response status code: \(statusCode)"

        case .corruptedData(let error):
            return "Server: data corrupted: \(error.localizedDescription)"

        case .serverStatus(let serverStatusCode, let errorMessage):
            
            if let errorMessage = errorMessage {
                
                return "Server: status: \(serverStatusCode) \(errorMessage)"
                
            } else {
                
                return "Server: status: \(serverStatusCode)"
            }
            
        case .notAuthorized:
            return "Not Authorized"
        }
    }
}

public extension Error {
    
    func isTimeoutError() -> Bool {
        
        let nsError = self as NSError
        
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut
    }
}

public extension ServerAgentError {
    
    func isTimeoutSAError() -> Bool {
        
        switch self {
            
        case .sessionError(let error):
            return error.isTimeoutError ()
            
        default:
            return false
        }
    }
}
