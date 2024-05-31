//
//  CardState.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

public enum CardState: Equatable {
    
    case active
    case status(CardState.Status?)
    
    public enum Status: Equatable {
        
        case activated
        case confirmActivate(ActivatePayload)
        case inflight
    }
    
    public typealias ActivatePayload = Int
}
