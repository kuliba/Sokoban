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
        let size, scale: String
        let loopedScrolling: Bool
        
        let list: [ListItem]
        
        public init(
            id: UUID = UUID(),
            title: String?,
            size: String,
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
        
        public struct ListItem: Equatable {
            
            let imageLink: String
            let link: String?
            let action: Action?
            
            public init(imageLink: String, link: String?, action: Action?) {
                self.imageLink = imageLink
                self.link = link
                self.action = action
            }
                        
            public struct Action: Equatable {
                
                let type: String
                let target: String?
                
                public init(type: String, target: String?) {
                    self.type = type
                    self.target = target
                }
            }
        }
    }
}

extension UILanding.Carousel.CarouselBase {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
