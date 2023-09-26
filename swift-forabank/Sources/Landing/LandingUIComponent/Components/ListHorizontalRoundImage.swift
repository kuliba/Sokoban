//
//  ListHorizontalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI
import Combine
import CombineSchedulers

public extension UILanding.List {
    
    struct HorizontalRoundImage: Hashable, Identifiable {
        
        public var id: Self { self }
        public let title: String?
        public let list: [ListItem]
        
        public struct ListItem: Hashable, Identifiable {
            
            public var id: Self { self }
            public let imageMd5Hash: String
            public let title, subInfo: String?
            public let detail: Detail?
            
            public struct Detail: Hashable {
                
                public let groupId, viewId: String
                
                public init(
                    groupId: String,
                    viewId: String
                ) {
                    self.groupId = groupId
                    self.viewId = viewId
                }
            }
            
            public init(
                imageMd5Hash: String,
                title: String?,
                subInfo: String?,
                detail: Detail?
            ) {
                self.imageMd5Hash = imageMd5Hash
                self.title = title
                self.subInfo = subInfo
                self.detail = detail
            }
        }
        
        public init(
            title: String?,
            list: [ListItem]
        ) {
            self.title = title
            self.list = list
        }
    }
}

extension ListHorizontalRoundImageView {
    
    final class ViewModel: ObservableObject {
        
        typealias HorizontalList = UILanding.List.HorizontalRoundImage
        
        @Published private(set) var data: HorizontalList
        
        @Published private(set) var images: [String: Image] = [:]
        
        init(
            data: HorizontalList,
            images: [String: Image]
        ) {
            self.data = data
            self.images = images
        }
        
        func image(byMd5Hash: String) -> Image? {
            
            return images[byMd5Hash]
        }
    }
}

extension UILanding.List.HorizontalRoundImage {
    
    func imageRequests() -> [ImageRequest] {
        
        return self.list.map(\.imageMd5Hash).map(ImageRequest.md5Hash)
    }
}
