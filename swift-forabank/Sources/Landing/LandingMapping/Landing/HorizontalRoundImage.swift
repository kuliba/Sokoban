//
//  HorizontalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Tagged

public extension Landing.DataView.List {
    
    struct HorizontalRoundImage: Equatable {
        
        public let title: String
        public let list: [ListItem]?
        
        public struct ListItem: Equatable {
            
            public let md5hash: String
            public let title, subInfo: String?
            public let detail: Detail?
            
            public init(
                md5hash: String,
                title: String?,
                subInfo: String?,
                details: Detail?
            ) {
                self.md5hash = md5hash
                self.title = title
                self.subInfo = subInfo
                self.detail = details
            }
            
            public struct Detail: Equatable {
                
                public let groupId: GroupId
                public let viewId: ViewId
                
                public init(
                    groupId: GroupId,
                    viewId: ViewId
                ) {
                    self.groupId = groupId
                    self.viewId = viewId
                }
                
                public typealias GroupId = Tagged<_GroupId, String>
                public typealias ViewId = Tagged<_ViewId, String>
                
                public enum _GroupId {}
                public enum _ViewId {}
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
