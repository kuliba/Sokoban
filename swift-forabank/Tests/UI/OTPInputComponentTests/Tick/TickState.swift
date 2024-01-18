//
//  TickState.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

struct TickState: Equatable {
    
    let core: Core
    let status: Status?
    
    init(_ core: Core, status: Status? = nil) {
        
        self.core = core
        self.status = status
    }
}

extension TickState {
    
    enum Core: Equatable {
        
        case idle
        case running(remaining: Int)
    }
    
    enum Status: Equatable {
        
        case failure(TickFailure)
    }
}
