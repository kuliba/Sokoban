//
//  ListHorizontalRectangleLimitsEffect.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation

public enum ListHorizontalRectangleLimitsEffect: Equatable {
    
    case loadSVCardLanding(String)
    case saveLimits([BlockHorizontalRectangularEvent.Limit])
    case showAlert(String, DispatchTimeInterval)
}
