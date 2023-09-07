//
//  LandingListHorizontalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

public extension Landing {
    
    struct ListHorizontalRoundImage: Equatable {
        
        public let title: String
        public let list: [ListItem]?
        
        public struct ListItem: Equatable {
            
            public let md5hash: String
            public let title, subInfo: String?
            public let detail: Detail
            
            public init(
                md5hash: String,
                title: String?,
                subInfo: String?,
                details: Detail
            ) {
                self.md5hash = md5hash
                self.title = title
                self.subInfo = subInfo
                self.detail = details
            }
            
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
        }
        
        public init(
            title: String,
            list: [ListItem]
        ) {
            self.title = title
            self.list = list
        }
    }
}
