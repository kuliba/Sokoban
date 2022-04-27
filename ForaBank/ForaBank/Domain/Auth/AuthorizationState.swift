//
//  AuthorizationState.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

enum AuthorizationState {
    
    case registerRequired
    case signInRequired(pincode: String)
    case unlockRequired(pincode: String)
    case authorized
}
