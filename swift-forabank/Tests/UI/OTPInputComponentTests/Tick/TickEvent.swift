//
//  TickEvent.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

enum TickEvent: Equatable {
    
    case appear
    case start
    case failure(Failure)
}

extension TickEvent {
    
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
}
