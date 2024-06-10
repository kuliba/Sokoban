//
//  ListHorizontalRectangleLimits.swift
//
//
//  Created by Andryusina Nataly on 10.06.2024.
//

import SwiftUI
import Combine

extension UILanding.List {
    
    public struct HorizontalRectangleLimits: Hashable {
        
        public let list: [Item]
        
        public init(list: [Item]) {
            self.list = list
        }

        public struct Item: Hashable, Identifiable {
            
            public var id: Self { self }
            public let action: Action
            public let limitType: String
            public let md5hash: String
            public let title: String
            public let limits: [Limit]
            
            public init(action: Action, limitType: String, md5hash: String, title: String, limits: [Limit]) {
                self.action = action
                self.limitType = limitType
                self.md5hash = md5hash
                self.title = title
                self.limits = limits
            }
            
            public struct Limit: Hashable, Identifiable {
                
                public let id: String
                public let title: String
                public let colorHEX: String
                
                public init(id: String, title: String, colorHEX: String) {
                    self.id = id
                    self.title = title
                    self.colorHEX = colorHEX
                }
            }
            
            public struct Action: Hashable, Identifiable {
                
                public var id: Self { self }
                public let type: String
                
                public init(type: String) {
                    self.type = type
                }
            }
        }
    }
}

extension ListHorizontalRectangleLimitsView {
    
    final class ViewModel: ObservableObject {
        
        typealias HorizontalList = UILanding.List.HorizontalRectangleLimits
        
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

extension UILanding.List.HorizontalRectangleLimits {
    
    func imageRequests() -> [ImageRequest] {
        
        return self.list.map(\.md5hash).map(ImageRequest.md5Hash)
    }
}
