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
            public let details: Details
            
            public init(
                md5hash: String,
                title: String?,
                subInfo: String?,
                details: Details
            ) {
                self.md5hash = md5hash
                self.title = title
                self.subInfo = subInfo
                self.details = details
            }
            
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
