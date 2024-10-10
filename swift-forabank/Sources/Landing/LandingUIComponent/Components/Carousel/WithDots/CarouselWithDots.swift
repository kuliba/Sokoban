//
//  CarouselWithDots.swift
//
//
//  Created by Andryusina Nataly on 30.09.2024.
//

import Foundation

public extension UILanding.Carousel {
    
    struct CarouselWithDots: Identifiable, Equatable {
        
        public let id: UUID
        let title: String?
        let size: Size
        let scale: String
        let loopedScrolling: Bool
        
        let list: [ListItem]
        
        public init(
            id: UUID = UUID(),
            title: String?,
            size: Size,
            scale: String,
            loopedScrolling: Bool,
            list: [ListItem]
        ) {
            self.id = id
            self.title = title
            self.size = size
            self.scale = scale
            self.loopedScrolling = loopedScrolling
            self.list = list
        }
        
        public struct Size: Equatable {
            
            public let width: Int
            public let height: Int
            
            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
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

extension UILanding.Carousel.CarouselWithDots {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
