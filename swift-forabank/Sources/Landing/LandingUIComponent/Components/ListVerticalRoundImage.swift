//
//  ListVerticalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Tagged
import Combine
import SwiftUI

extension UILanding.List {
    
    public struct VerticalRoundImage: Equatable {
        
        let id: UUID
        let title: String?
        let displayedCount: Double?
        let dropButtonOpenTitle, dropButtonCloseTitle: String?
        let list: [ListItem]
        
        public struct ListItem: Identifiable, Equatable {
            
            public let id: UUID
            let md5hash: String
            let title, subInfo: String?
            let link, appStore, googlePlay: String?
            
            let detail: Detail?
            let action: Action?

            public struct Detail: Equatable {
                
                let groupId: GroupId
                let viewId: ViewId
                
                public init(groupId: GroupId, viewId: ViewId) {
                    self.groupId = groupId
                    self.viewId = viewId
                }
            }
            
            public struct Action: Equatable {
                let type: String
                
                public init(type: String) {
                    self.type = type
                }
            }
            
            public init(
                id: UUID = UUID(),
                md5hash: String,
                title: String?,
                subInfo: String?,
                link: String?,
                appStore: String?,
                googlePlay: String?,
                detail: Detail?,
                action: Action?
            ) {
                self.id = id
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
            id: UUID = UUID(),
            title: String?,
            displayedCount: Double?,
            dropButtonOpenTitle: String?,
            dropButtonCloseTitle: String?,
            list: [ListItem]
        ) {
            self.id = id
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

extension ListVerticalRoundImageView {
    
    final class ViewModel: ObservableObject {
        
        typealias VerticalRoundImageList = UILanding.List.VerticalRoundImage
        
        @Published private(set) var data: VerticalRoundImageList
        @Published private(set) var images: [String: Image] = [:]
        
        private let selectDetail: SelectDetail

        init(
            data: VerticalRoundImageList,
            images: [String: Image],
            selectDetail: @escaping SelectDetail
        ) {
            self.data = data
            self.images = images
            self.selectDetail = selectDetail
        }
        
        func image(byMd5Hash: String) -> Image? {
            
            return images[byMd5Hash]
        }
        
        static func action(
            item: UILanding.List.VerticalRoundImage.ListItem,
            selectDetail: SelectDetail
        ) {
            
            if let detailDestination = item.detailDestination {
                selectDetail(detailDestination)
            } else if let url = item.urlForOpen {
                UIApplication.shared.open(url, options: [:], completionHandler: nil) }
        }

        func action(
            for item: VerticalRoundImageList.ListItem
        ) {
            
            Self.action(item: item, selectDetail: selectDetail)
        }
        
        func list(
            showAll: Bool
        ) -> [UILanding.List.VerticalRoundImage.ListItem] {
            return showAll ? data.list : Array(data.list[..<displayedCount])
        }
        
        var displayedCount: Int {
            data.displayedCount.map(Int.init) ?? data.list.count
        }
    }
}

extension UILanding.List.VerticalRoundImage {
    
    func imageRequests() -> [ImageRequest] {
        
        return self.list.map { .md5Hash($0.md5hash)}
    }
}

extension UILanding.List.VerticalRoundImage.ListItem {
    
    var detailDestination: DetailDestination? {
        
        detail.map {
            .init(
                groupID: .init($0.groupId.rawValue),
                viewID: .init($0.viewId.rawValue)
            )
        }
    }
    
    var urlForOpen: URL? {
        
        if let url = urlForOpen(self.link) { return url }
        else if let url = urlForOpen(self.appStore) { return url }
        else if let url = urlForOpen(self.googlePlay) { return url }
        return nil
    }
    
    func urlForOpen(
        _ link: String?
    ) -> URL? {
        
        if let link, let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            return url
        }
        return nil
    }
}

extension UILanding.List.VerticalRoundImage.ListItem {
    
    var disableAction: Bool {
        
        return self.detail == nil
        && self.appStore.isNilOrEmpty
        && self.googlePlay.isNilOrEmpty
        && self.link.isNilOrEmpty
    }
}

extension Optional where Wrapped == String {

    public var isNilOrEmpty: Bool {
        if let text = self, !text.isEmpty { return false }
        return true
    }
}
