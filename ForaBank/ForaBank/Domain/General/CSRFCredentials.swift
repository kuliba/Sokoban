//
//  CSRFCredentials.swift
//  ForaBank
//
//  Created by Max Gribov on 03.03.2022.
//

import Foundation

struct CSRFCredentials {
    
    let token: String
    let csrfAgent: CSRFAgent<AESEncryptionAgent>
}

enum CSRFError: Error {
    
    case unexpected(status: ServerStatusCode, errorMessage: String?)
    case serverError(ServerAgentError)
    case csrfAgentInitError(Error)
}
