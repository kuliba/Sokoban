//
//  SessionState.swift
//  ForaBank
//
//  Created by Max Gribov on 20.04.2022.
//

import Foundation

enum SessionState {
    
    case inactive
    case active(start: TimeInterval, credentials: SessionCredentials)
    case expired
    case failed(Error)
}

extension SessionState: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        switch self {
        case .inactive: return "INACTIVE"
        case .active: return "ACTIVE"
        case .expired: return "EXPIRED"
        case .failed: return "FAILED"
        }
    }
}
