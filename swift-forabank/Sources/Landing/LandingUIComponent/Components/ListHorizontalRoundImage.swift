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
    
    struct HorizontalRoundImage: Equatable {
       
        let id: UUID
        let title: String?
        let list: [ListItem]
        
        public struct ListItem: Equatable {
            
            let imageMd5Hash: String
            let title, subInfo: String?
            let detail: Detail?
            
            public struct Detail: Equatable {
                
                let groupId, viewId: String
                
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
            id: UUID = UUID(),
            title: String?,
            list: [ListItem]
        ) {
            self.id = id
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
