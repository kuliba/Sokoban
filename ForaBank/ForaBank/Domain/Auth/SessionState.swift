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
