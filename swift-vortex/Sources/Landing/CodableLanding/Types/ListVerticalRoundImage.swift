//
//  ListVerticalRoundImageCodable.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Tagged

extension CodableLanding.List {
    
    public struct VerticalRoundImage: Codable, Equatable {
        
        public let title: String?
        public let displayedCount: Double?
        public let dropButtonOpenTitle, dropButtonCloseTitle: String?

        public let list: [ListItem?]
        
        public struct ListItem: Codable, Equatable {
            
            public let md5hash: String
            public let title, subInfo: String?
            public let link, appStore, googlePlay: String?

            public let detail: Detail?
            public let action: Action?
            
            public struct Detail: Codable, Equatable {
                
                public let groupId: GroupId
                public let viewId: ViewId
                
                public init(groupId: GroupId, viewId: ViewId) {
                    self.groupId = groupId
                    self.viewId = viewId
                }
            }
            
            public struct Action: Codable, Equatable {
                public let type: String
                
                public init(type: String) {
                    self.type = type
                }
            }

            public init(md5hash: String, title: String?, subInfo: String?, link: String?, appStore: String?, googlePlay: String?, detail: Detail?, action: Action?) {
                self.md5hash = md5hash
                self.title = title
                self.subInfo = subInfo
                self.link = link
                self.appStore = appStore
                self.googlePlay = googlePlay
                self.detail = detail
                self.action = action
            }
        }
        
        public init(
            title: String?,
            displayedCount: Double?,
            dropButtonOpenTitle: String?,
            dropButtonCloseTitle: String?,
            list: [ListItem?]
        ) {
            self.title = title
            self.displayedCount = displayedCount
            self.dropButtonOpenTitle = dropButtonOpenTitle
            self.dropButtonCloseTitle = dropButtonCloseTitle
            self.list = list
        }
        
        public typealias GroupId = Tagged<_GroupId, String>
        public typealias ViewId = Tagged<_ViewId, String>
        
        public enum _GroupId {}
        public enum _ViewId {}
    }
}
