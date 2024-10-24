//
//  CodableCarouselWithTabs.swift
//
//
//  Created by Andryusina Nataly on 27.09.2024.
//

import Foundation

public extension CodableLanding {
    
    struct CodableCarouselWithTabs: Codable, Equatable {
        
        public let title: String?
        public let size: Size
        public let loopedScrolling: Bool
        public let tabs: [TabItem]
                
        public init(
            title: String?,
            size: Size,
            loopedScrolling: Bool,
            tabs: [TabItem]
        ) {
            self.title = title
            self.size = size
            self.loopedScrolling = loopedScrolling
            self.tabs = tabs
        }
        
        public struct Size: Codable, Equatable {
            
            public let width: Int
            public let height: Int
            
            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
        }
        
        public struct TabItem: Codable, Equatable {
            
            public let name: String
            public let list: [ListItem]
            
            public init(name: String, list: [ListItem]) {
                self.name = name
                self.list = list
            }
        }

        public struct ListItem: Codable, Equatable {
            
            public let imageLink: String
            public let link: String?
            public let action: Action?
            
            public init(imageLink: String, link: String?, action: Action?) {
                self.imageLink = imageLink
                self.link = link
                self.action = action
            }
            
            public struct Action: Codable, Equatable {
                
                public let type: String
                public let target: String?
                
                public init(type: String, target: String?) {
                    self.type = type
                    self.target = target
                }
            }
        }
    }
}
