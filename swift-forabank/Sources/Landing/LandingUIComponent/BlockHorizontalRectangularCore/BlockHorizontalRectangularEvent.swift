//
//  BlockHorizontalRectangularEvent.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation

public enum BlockHorizontalRectangularEvent: Equatable {
    
    case edit(Limit)
    
    public struct Limit: Equatable {
        
        public let id: String
        public let value: Decimal
        
        public init(id: String, value: Decimal) {
            self.id = id
            self.value = value
        }
    }
}
