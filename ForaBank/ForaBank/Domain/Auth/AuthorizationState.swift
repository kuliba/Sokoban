//
//  AuthorizationState.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

enum AuthorizationState {
    
    case registerRequired
    case signInRequired
    case unlockRequired
    case unlockRequiredManual
    case authorized
}
