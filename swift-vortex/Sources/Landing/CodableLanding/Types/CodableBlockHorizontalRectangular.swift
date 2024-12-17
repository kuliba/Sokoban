//
//  CodableBlockHorizontalRectangular.swift
//
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import Foundation

public extension CodableLanding {
    
    struct BlockHorizontalRectangular: Codable, Equatable  {
        
        public let list: [Item]
        
        public init(list: [Item]) {
            self.list = list
        }
        
        public struct Item: Codable, Equatable {
            
            public let limitType: String
            public let description: String
            public let title: String
            public let limits: [Limit]
            
            public init(limitType: String, description: String, title: String, limits: [Limit]) {
                self.limitType = limitType
                self.description = description
                self.title = title
                self.limits = limits
            }
            
            public struct Limit: Codable, Equatable {
                public let id: String
                public let title: String
                public let md5hash: String
                public let text: String
                public let maxSum: Decimal
                
                public init(id: String, title: String, md5hash: String, text: String, maxSum: Decimal) {
                    self.id = id
                    self.title = title
                    self.md5hash = md5hash
                    self.text = text
                    self.maxSum = maxSum
                }
            }
        }
    }
}
