//
//  AuthorizationState.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

enum AuthorizationState {
    
    case notAuthorized
    case authorized(token: String, csrfAgent: CSRFAgent<AESEncryptionAgent>)
}
