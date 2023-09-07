//
//  ListHorizontalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension Landing {
    
    struct ListHorizontalRoundImage: Equatable, Identifiable {
        
        public let id = UUID()
        public let title: String?
        public let list: [ListItem]
        public let config: Config
        
        public struct ListItem: Equatable, Identifiable {
            
            public let id = UUID()
            public let image: Image
            public let title, subInfo: String?
            public let detail: Detail?
            
            public struct Detail: Equatable {
                
                public let groupId, viewId: String
                
                public init(
                    groupId: String,
                    viewId: String
                ) {
                    self.groupId = groupId
                    self.viewId = viewId
                }
            }
            
            public init(
                image: Image,
                title: String?,
                subInfo: String?,
                detail: Detail?
            ) {
                self.image = image
                self.title = title
                self.subInfo = subInfo
                self.detail = detail
            }
        }
        
        public init(
            title: String?,
            list: [ListItem],
            config: Config
        ) {
            self.title = title
            self.list = list
            self.config = config
        }
    }
}
