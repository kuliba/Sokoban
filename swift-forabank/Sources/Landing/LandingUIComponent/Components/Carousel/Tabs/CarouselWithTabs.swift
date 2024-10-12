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
        let scale: String
        let loopedScrolling: Bool
        let tabs: [TabItem]
        
        public init(
            id: UUID = UUID(),
            title: String?,
            size: Size,
            scale: String,
            loopedScrolling: Bool,
            tabs: [TabItem]
        ) {
            self.id = id
            self.title = title
            self.size = size
            self.scale = scale
            self.loopedScrolling = loopedScrolling
            self.tabs = tabs
        }
        
        public struct Size: Equatable {
            
            public let width: Int
            public let height: Int
            
            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
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
            
            let imageLink: String
            let link: String?
            let action: ItemAction?
            
            public init(imageLink: String, link: String?, action: ItemAction?) {
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
