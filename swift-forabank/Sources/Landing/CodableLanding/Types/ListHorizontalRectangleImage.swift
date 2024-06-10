//
//  ListHorizontalRectangleImage.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Foundation

extension CodableLanding.List {
    
    public struct HorizontalRectangleImage: Codable, Equatable {
        
        public let list: [Item]
        
        public struct Item: Codable, Equatable {
            
            public let imageLink: String
            public let link: String
            public let detail: Detail?
            
            public struct Detail: Codable, Equatable {
                public let groupId: String
                public let viewId: String
                
                public init(groupId: String, viewId: String) {
                    self.groupId = groupId
                    self.viewId = viewId
                }
            }
            
            public init(imageLink: String, link: String, detail: Detail?) {
                self.imageLink = imageLink
                self.link = link
                self.detail = detail
            }
        }
        
        public init(list: [Item]) {
            self.list = list
        }
    }
}
