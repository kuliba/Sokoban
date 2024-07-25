//
//  SVCardLimits.swift
//
//
//  Created by Andryusina Nataly on 17.07.2024.
//

import Foundation

public struct SVCardLimits: Equatable {
    
    public let limitsList: [LimitItem]

    public init(limitsList: [LimitItem]) {
        self.limitsList = limitsList
    }
    
    public struct LimitItem: Equatable {
        
        public let type: String
        public let limits: [LimitValues]
        
        public init(type: String, limits: [LimitValues]) {
            self.type = type
            self.limits = limits
        }
    }
}
