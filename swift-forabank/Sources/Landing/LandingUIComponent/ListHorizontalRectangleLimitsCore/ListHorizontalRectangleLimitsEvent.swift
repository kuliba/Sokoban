//
//  ListHorizontalRectangleLimitsEvent.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation

public enum ListHorizontalRectangleLimitsEvent: Equatable {
    
    case buttonTapped(Info)
    
    public struct Info: Equatable {
        let limitType: String
        let action: String
        
        public init(limitType: String, action: String) {
            self.limitType = limitType
            self.action = action
        }
    }
}
