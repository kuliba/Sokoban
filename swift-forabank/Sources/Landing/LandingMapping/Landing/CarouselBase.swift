//
//  CarouselBase.swift
//  
//
//  Created by Andryusina Nataly on 26.09.2024.
//

public extension Landing.DataView.Carousel {
    
    struct CarouselBase: Equatable {
        
        public let title: String?
        public let size, scale: String
        public let loopedScrolling: Bool
        
        public let list: [ListItem]
        
        public init(
            title: String?,
            size: String,
            scale: String, 
            loopedScrolling: Bool,
            list: [ListItem]
        ) {
            self.title = title
            self.size = size
            self.scale = scale
            self.loopedScrolling = loopedScrolling
            self.list = list
        }
        
        public struct ListItem: Equatable {
            
            public let imageLink: String
            public let link: String?
            public let action: Action?
            
            public init(imageLink: String, link: String?, action: Action?) {
                self.imageLink = imageLink
                self.link = link
                self.action = action
            }
                        
            public struct Action: Equatable {
                
                public let type: String
                public let target: String?
                
                public init(type: String, target: String?) {
                    self.type = type
                    self.target = target
                }
            }
        }
    }
}
