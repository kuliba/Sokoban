//
//  ActivateSlider+Event.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import Foundation

public extension ActivateSlider {
    
    enum Event: Equatable {
        
        case swipe
        case alertTap(AlertEvent)
        case inflight
        case activateCardResponse(ActivateCardResponse)

        public enum ActivateCardResponse: Equatable {
            
            case success
            case connectivityError
            case serverError(String)
        }
        
        public enum AlertEvent: Equatable {
            
            case cancel
            case activate
        }
    }
}
