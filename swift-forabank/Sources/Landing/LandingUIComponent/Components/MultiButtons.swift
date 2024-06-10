//
//  MultiButtons.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Tagged
import Combine
import UIKit

public extension UILanding.Multi {
    
    struct Buttons: Equatable {
        
        public let id: UUID
        public let list: [Item]
        
        public struct Item: Equatable {
            
            public let id: UUID
            public let text: String
            public let style: String
            public let detail: Detail?
            public let link: String?
            public let action: Action?
            
            public struct Detail: Hashable {
                
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
            
            public struct Action: Hashable {
                
                public let type: ActionType
                
                public init(type: ActionType) {
                    self.type = type
                }
                
                public typealias ActionType = Tagged<_ActionType, String>
                
                public enum _ActionType {}
            }
            
            public init(
                id: UUID = UUID(),
                text: String,
                style: String,
                detail: Detail?,
                link: String?,
                action: Action?
            ) {
                self.id = id
                self.text = text
                self.style = style
                self.detail = detail
                self.link = link
                self.action = action
            }
            
            func actionType(
                by action: Item.Action.ActionType
            ) -> LandingActionType? {
                LandingActionType(rawValue: action.rawValue)
            }
        }
        
        public init(id: UUID = UUID(), list: [Item]) {
            self.id = id
            self.list = list
        }
    }
}

extension MultiButtonsView {
    
    final class ViewModel: ObservableObject {
        
        @Published private(set) var data: UILanding.Multi.Buttons
        
        private let selectDetail: SelectDetail
        private let action: (LandingEvent) -> Void
        
        init(
            data: UILanding.Multi.Buttons,
            selectDetail: @escaping SelectDetail,
            action: @escaping (LandingEvent) -> Void
        ) {
            self.data = data
            self.selectDetail = selectDetail
            self.action = action
        }
        
        static func itemAction(
            item: UILanding.Multi.Buttons.Item,
            selectDetail: SelectDetail,
            action: (LandingEvent) -> Void,
            openLink: @escaping () -> Void
        ) {
            
            if let type = item.action?.type,
                let actionType = item.actionType(by: type) {
                switch actionType {
                case .goToMain:
                    action(.card(.goToMain))
                case .orderCard:
                    break
                case .goToOrderSticker:
                    action(.sticker(.order))
                }
            } else if let detailDestination = item.detailDestination {
                selectDetail(detailDestination)
            } else {
                openLink()
            }
        }
        
        func itemAction(
            item: UILanding.Multi.Buttons.Item
        ) {
            
           Self.itemAction(
                item: item,
                selectDetail: selectDetail,
                action: action,
                openLink: { self.openLink(item.link) }
            )
        }
        
        func openLink(
            _ link: String?
        ) {
            guard let strUrl = link, let url = URL(string: strUrl)
            else { return }
            
            UIApplication.shared.open(url)
        }
    }
}

extension UILanding.Multi.Buttons {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}

extension UILanding.Multi.Buttons.Item {
    
    var detailDestination: DetailDestination? {
        
        detail.map {
            .init(
                groupID: .init($0.groupId.rawValue),
                viewID: .init($0.viewId.rawValue)
            )
        }
    }
}
