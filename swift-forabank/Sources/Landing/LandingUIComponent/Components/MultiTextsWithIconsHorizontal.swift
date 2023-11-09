//
//  MultiTextsWithIconsHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension UILanding.Multi {
    
    struct TextsWithIconsHorizontal: Hashable {
        
        public let lists: [Item]
        
        public struct Item: Hashable, Identifiable {
            
            public var id: Self { self }
            public let md5hash: String
            public let title: String?
            
            public init(
                md5hash: String,
                title: String?
            ) {
                self.md5hash = md5hash
                self.title = title
            }
        }
        
        public init(lists: [Item]) {
            
            self.lists = lists
        }
    }
}

extension MultiTextsWithIconsHorizontalView {
    
    final class ViewModel: ObservableObject {
        
        typealias MultiTextsWithIconsHorizontal = UILanding.Multi.TextsWithIconsHorizontal
        
        @Published private(set) var data: MultiTextsWithIconsHorizontal
        
        @Published private(set) var images: [String: Image] = [:]
        
        init(
            data: MultiTextsWithIconsHorizontal,
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

extension UILanding.Multi.TextsWithIconsHorizontal {
    
    func imageRequests() -> [ImageRequest] {
        
        return self.lists.map(\.md5hash).map(ImageRequest.md5Hash)
    }
}
