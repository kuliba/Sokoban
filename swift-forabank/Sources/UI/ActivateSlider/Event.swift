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
        case inflight
        case activateCardResponse(ActivateCardResponse)

        public enum ActivateCardResponse: Equatable {
            
            case success
            case connectivityError
            case serverError(String)
        }
    }
}
