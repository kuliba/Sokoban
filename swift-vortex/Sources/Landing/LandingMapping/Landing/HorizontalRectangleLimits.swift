//
//  HorizontalRectangleLimits.swift
//  
//
//  Created by Andryusina Nataly on 07.06.2024.
//

import Foundation

public extension Landing.DataView.List {
    
    struct HorizontalRectangleLimits: Equatable {
        
        public let list: [Item]
        
        public struct Item: Equatable {
            
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
            
            public struct Limit: Equatable {
                public let id: String
                public let title: String
                public let colorHEX: String
                
                public init(id: String, title: String, colorHEX: String) {
                    self.id = id
                    self.title = title
                    self.colorHEX = colorHEX
                }
            }
            
            public struct Action: Equatable {
                public let type: String
                
                public init(type: String) {
                    self.type = type
                }
            }
        }
    }
}
