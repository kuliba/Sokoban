//
//  CarouselBase.swift
//  
//
//  Created by Andryusina Nataly on 26.09.2024.
//

import Foundation

public extension Landing.DataView.Carousel {
    
    struct CarouselBase: Equatable {
        
        public let title: String?
        public let size: Size
        public let loopedScrolling: Bool
        
        public let list: [ListItem]
        
        public init(
            title: String?,
            size: Size,
            loopedScrolling: Bool,
            list: [ListItem]
        ) {
            self.title = title
            self.size = size
            self.loopedScrolling = loopedScrolling
            self.list = list
        }
        
        public struct Size: Equatable {
            
            public let width: CGFloat
            public let height: CGFloat
            
            public init(width: CGFloat, height: CGFloat) {
                self.width = width
                self.height = height
            }
            
            public init(size: String, scale: CGFloat) {
                let allNumbers = size.allNumbers
                self.width = CGFloat(!allNumbers.isEmpty ? allNumbers[0] : 0) * scale
                self.height = CGFloat(allNumbers.count > 1 ? allNumbers[1] : 0) * scale
            }
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
