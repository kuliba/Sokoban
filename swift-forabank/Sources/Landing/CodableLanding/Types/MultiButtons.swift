//
//  MultiButtons.swift
//  
//
//  Created by Andryusina Nataly on 06.09.2023.
//

import Tagged

public extension CodableLanding.Multi {
    
    struct Buttons: Equatable, Codable {
        
        public let list: [Item]
        
        public struct Item: Equatable, Codable {
            
            public let text: String
            public let style: String
            public let detail: Detail?
            public let link: String?
            public let action: Action?
            
            public struct Detail: Equatable, Codable {
                
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
            
            public struct Action: Equatable, Codable {
                
                public let type: ActionType
                
                public init(type: ActionType) {
                    self.type = type
                }
                
                public typealias ActionType = Tagged<_ActionType, String>
                
                public enum _ActionType {}

            }
            
            public init(text: String, style: String, detail: Detail?, link: String?, action: Action?) {
                self.text = text
                self.style = style
                self.detail = detail
                self.link = link
                self.action = action
            }
        }
        
        public init(list: [Item]) {
            self.list = list
        }
    }
}
