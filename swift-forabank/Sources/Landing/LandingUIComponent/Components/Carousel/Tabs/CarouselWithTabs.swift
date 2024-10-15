//
//  CarouselWithTabs.swift
//
//
//  Created by Andryusina Nataly on 27.09.2024.
//

import Foundation

public extension UILanding.Carousel {
    
    struct CarouselWithTabs: Identifiable, Equatable {
        
        public let id: UUID
        let title: String?
        let size: Size
        let loopedScrolling: Bool
        let tabs: [TabItem]
        
        public init(
            id: UUID = UUID(),
            title: String?,
            size: Size,
            loopedScrolling: Bool,
            tabs: [TabItem]
        ) {
            self.id = id
            self.title = title
            self.size = size
            self.loopedScrolling = loopedScrolling
            self.tabs = tabs
        }
        
        public struct TabItem: Equatable {
            
            public let name: String
            public let list: [ListItem]
            
            public init(name: String, list: [ListItem]) {
                self.name = name
                self.list = list
            }
        }

        public struct ListItem: Equatable {
            
            public let id: UUID
            let imageLink: String
            let link: String?
            let action: ItemAction?
            
            public init(
                id: UUID = UUID(),
                imageLink: String,
                link: String?,
                action: ItemAction?
            ) {
                self.id = id
                self.imageLink = imageLink
                self.link = link
                self.action = action
            }
        }
    }
}

extension UILanding.Carousel.CarouselWithTabs {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
