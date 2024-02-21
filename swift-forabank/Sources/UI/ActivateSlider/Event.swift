//
//  ActivateSlider+Event.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import Foundation

public extension ActivateSlider {
    
    enum Event: Equatable {
        
        case activateCardResponse(ActivateCardResponse)
        case alertTap(AlertEvent)
        case inflight
        case swipe

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
}
