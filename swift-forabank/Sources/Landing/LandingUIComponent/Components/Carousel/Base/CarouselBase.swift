//
//  CarouselBase.swift
//  
//
//  Created by Andryusina Nataly on 26.09.2024.
//

import Foundation

public extension UILanding.Carousel {
    
    struct CarouselBase: Identifiable, Equatable {
        
        public let id: UUID
        let title: String?
        let size: Size
        let loopedScrolling: Bool
        
        let list: [ListItem]
        
        public init(
            id: UUID = UUID(),
            title: String?,
            size: Size,
            loopedScrolling: Bool,
            list: [ListItem]
        ) {
            self.id = id
            self.title = title
            self.size = size
            self.loopedScrolling = loopedScrolling
            self.list = list
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

extension UILanding.Carousel.CarouselBase {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
