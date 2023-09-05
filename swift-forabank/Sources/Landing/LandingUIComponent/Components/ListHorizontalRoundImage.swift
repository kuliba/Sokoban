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
            public let details: Details?
            
            public struct Details: Equatable {
                
                public let detailsGroupId, detailViewId: String
                
                public init(
                    detailsGroupId: String,
                    detailViewId: String
                ) {
                    self.detailsGroupId = detailsGroupId
                    self.detailViewId = detailViewId
                }
            }
            
            public init(
                image: Image,
                title: String?,
                subInfo: String?,
                details: Details?
            ) {
                self.image = image
                self.title = title
                self.subInfo = subInfo
                self.details = details
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
