//
//  SessionCredentials.swift
//  Vortex
//
//  Created by Max Gribov on 03.03.2022.
//

import Foundation
import ServerAgent

struct SessionCredentials {

    let token: String
#if MOCK
    let csrfAgent: MockCSRFAgent<MockEncryptionAgent>
#else
    let csrfAgent: any CSRFAgentProtocol
#endif
    
}

enum CSRFError: LocalizedError {
    
    case unexpected(status: ServerStatusCode, errorMessage: String?)
    case serverError(ServerAgentError)
    case csrfAgentInitError(Error)
    
    var errorDescription: String? {
        
        switch self {
        case .unexpected(let status, let errorMessage):
            if let errorMessage = errorMessage {
                
                return "Unexpected status: \(status), message: \(errorMessage)"
                
            } else {
                
                return "Unexpected status: \(status)"
            }
            
        case .serverError(let serverAgentError):
            return "Server agent error: \(serverAgentError.localizedDescription)"
            
        case .csrfAgentInitError(let error):
            return "CSRF agent error: \(error.localizedDescription)"
        }
    }
}
