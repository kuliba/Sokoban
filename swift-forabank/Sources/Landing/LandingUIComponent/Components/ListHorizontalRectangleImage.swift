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
        
        public let id: UUID
        public let list: [Item]
        
        public struct Item: Equatable {
            
            public let imageLink: String
            public let link: String
            public let detail: Detail?
            
            public struct Detail: Hashable {
                public let groupId: String
                public let viewId: String
                
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
        
        init(
            data: HorizontalList,
            images: [String: Image]
        ) {
            self.data = data
            self.images = images
        }
        
        func image(byImageLink: String) -> Image? {
            
            return images[byImageLink]
        }
    }
}

extension UILanding.List.HorizontalRectangleImage {
    
    func imageRequests() -> [ImageRequest] {
        
        return self.list.map(\.imageLink).map(ImageRequest.url)
    }
}
