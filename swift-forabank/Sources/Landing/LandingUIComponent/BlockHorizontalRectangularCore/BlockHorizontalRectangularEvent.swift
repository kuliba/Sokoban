//
//  BlockHorizontalRectangularEvent.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation

public enum BlockHorizontalRectangularEvent: Equatable {
    
    case change(Limit)
    
    public struct Limit: Equatable {
        
        let id: String
        let value: String
        
        public init(id: String, value: String) {
            self.id = id
            self.value = value
        }
    }
}
