//
//  VerticalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Tagged

extension Landing.DataView.List {
    
    public struct VerticalRoundImage: Decodable, Equatable {
        
        public let title: String?
        public let displayedCount: Double?
        public let dropButtonOpenTitle, dropButtonCloseTitle: String?

        public let list: [ListItem?]
        
        public struct ListItem: Decodable, Equatable {
            
            public let md5hash: String
            public let title, subInfo: String?
            public let link, appStore, googlePlay: String?

            public let detail: Detail?
            
            public struct Detail: Decodable, Equatable {
                
                public let groupId: GroupId
                public let viewId: ViewId
                
                public init(groupId: GroupId, viewId: ViewId) {
                    self.groupId = groupId
                    self.viewId = viewId
                }
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
