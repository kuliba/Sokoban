//
//  CardEvent.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import Foundation

public enum CardEvent: Equatable {
    
    case activateCardResponse(ActivateCardResponse)
    case activateCard // show
    case confirmActivate(AlertEvent)
    case dismissActivate
    
    public enum ActivateCardResponse: Equatable {
        
        case connectivityError
        case serverError(String)
        case success
    }
    
    public enum AlertEvent: Equatable {
        
        case activate
        case cancel
    }
}

