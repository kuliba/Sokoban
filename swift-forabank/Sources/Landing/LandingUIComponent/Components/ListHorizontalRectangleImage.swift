//
//  ListHorizontalRectangleImage.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import SwiftUI
import Combine

extension UILanding.List {
    
    public struct HorizontalRectangleImage: Equatable {
        
        let id: UUID
        let list: [Item]
        
        public struct Item: Equatable {
            
            let imageLink: String
            let link: String
            let detail: Detail?
            
            public struct Detail: Hashable {
                let groupId: String
                let viewId: String
                
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
        
        public init(id: UUID = UUID(), list: [Item]) {
            self.id = id
            self.list = list
        }
    }
}

extension ListHorizontalRectangleImageView {
    
    final class ViewModel: ObservableObject {
        
        typealias HorizontalList = UILanding.List.HorizontalRectangleImage
        
        @Published private(set) var data: HorizontalList
        
        @Published private(set) var images: [String: Image] = [:]
        
        private let action: (LandingEvent) -> Void
        private let selectDetail: SelectDetail
        private let canOpenDetail: UILanding.CanOpenDetail

        init(
            data: HorizontalList,
            images: [String: Image],
            action: @escaping (LandingEvent) -> Void,
            selectDetail: @escaping SelectDetail,
            canOpenDetail: @escaping UILanding.CanOpenDetail
        ) {
            self.data = data
            self.images = images
            self.action = action
            self.selectDetail = selectDetail
            self.canOpenDetail = canOpenDetail
        }
        
        func image(byImageLink: String) -> Image? {
            
            return images[byImageLink]
        }
        
        static func itemAction(
            item: HorizontalList.Item,
            selectDetail: SelectDetail,
            action: (LandingEvent) -> Void,
            canOpenDetail: UILanding.CanOpenDetail
        ) {
            if let detailDestination = item.detailDestination {
                if canOpenDetail(detailDestination) {
                    selectDetail(detailDestination)
                } else if let bannerAction = detailDestination.groupID.bannerAction {
                    action(.bannerAction(bannerAction))
                } else if !item.link.isEmpty {
                    action(.card(.openUrl(item.link)))
                }
            } else if !item.link.isEmpty {
                action(.card(.openUrl(item.link)))
            }
        }
        
        func itemAction(
            item: HorizontalList.Item
        ) {
            
           Self.itemAction(
                item: item,
                selectDetail: selectDetail,
                action: action, 
                canOpenDetail: canOpenDetail
            )
        }
    }
}

extension UILanding.List.HorizontalRectangleImage {
    
    func imageRequests() -> [ImageRequest] {
        
        return self.list.map(\.imageLink).map(ImageRequest.url)
    }
}

private extension String {
    
    var bannerAction: LandingEvent.BannerAction? {
        
        switch self {
            
        case "DEPOSIT_OPEN":
            return .openDeposit
        case "DEPOSITS":
            return .depositsList
        case "MIG_TRANSFER":
            return .migTransfer
        case "MIG_AUTH_TRANSFER":
            return .migAuthTransfer
        case "CONTACT_TRANSFER":
            return .contact
        case "DEPOSIT_TRANSFER":
            return .depositTransfer
        case "LANDING":
            return .landing
        default:
            return nil
        }
    }
}
