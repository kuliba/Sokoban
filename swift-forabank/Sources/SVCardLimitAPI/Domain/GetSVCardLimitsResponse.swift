//
//  GetSVCardLimitsResponse.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import Foundation

public struct GetSVCardLimitsResponse: Equatable {
    
    public let limitsList: [LimitItem]
    public let serial: String?

    public init(limitsList: [LimitItem], serial: String?) {
        self.limitsList = limitsList
        self.serial = serial
    }
    
    public struct LimitItem: Equatable {
        
        public let type: String
        public let limits: [Limit]
        
        public init(type: String, limits: [Limit]) {
            self.type = type
            self.limits = limits
        }
        
        public struct Limit: Equatable {
           
            public let currency: Int
            public let currentValue: Decimal
            public let name: String
            public let value: Decimal
            
            public init(
                currency: Int,
                currentValue: Decimal,
                name: String,
                value: Decimal
            ) {
                self.currency = currency
                self.currentValue = currentValue
                self.name = name
                self.value = value
            }
        }
    }
}
