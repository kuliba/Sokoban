//
//  ChangeSVCardLimitPayload.swift
//
//
//  Created by Andryusina Nataly on 14.06.2024.
//

import Foundation

public struct ChangeSVCardLimitPayload: Equatable {

    public let cardId: Int
    public let limit: Limit
    
    public init(cardId: Int, limit: Limit) {
        self.cardId = cardId
        self.limit = limit
    }
    
    public struct Limit: Equatable {
        
        public let name: String
        public let value: Decimal
        
        public init(name: String, value: Decimal) {
            self.name = name
            self.value = value
        }
    }
}
