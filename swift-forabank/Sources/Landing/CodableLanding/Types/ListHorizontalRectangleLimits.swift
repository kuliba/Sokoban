//
//  ListHorizontalRectangleLimits.swift
//
//
//  Created by Andryusina Nataly on 10.06.2024.
//

import Foundation

extension CodableLanding.List {
    
    public struct HorizontalRectangleLimits: Codable, Equatable {
        
        public let list: [Item]
        
        public init(list: [Item]) {
            self.list = list
        }
        
        public struct Item: Codable, Equatable {
            public let action: Action
            public let limitType: String
            public let md5hash: String
            public let title: String
            
            public let limits: [Limit]
            
            public init(action: Action, limitType: String, md5hash: String, title: String, limits: [Limit]) {
                self.action = action
                self.limitType = limitType
                self.md5hash = md5hash
                self.title = title
                self.limits = limits
            }
            
            public struct Limit: Codable, Equatable {
                public let id: String
                public let title: String
                public let colorHEX: String
                
                public init(id: String, title: String, colorHEX: String) {
                    self.id = id
                    self.title = title
                    self.colorHEX = colorHEX
                }
            }
            
            public struct Action: Codable, Equatable {
                public let type: String
                
                public init(type: String) {
                    self.type = type
                }
            }
        }
    }
}
