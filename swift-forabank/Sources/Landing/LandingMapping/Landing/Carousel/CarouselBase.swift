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
        public let scale: String
        public let loopedScrolling: Bool
        
        public let list: [ListItem]
        
        public init(
            title: String?,
            size: Size,
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
        
        public struct Size: Equatable {
            
            public let width: Int
            public let height: Int
            
            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
            
            public init(size: String) {
                let allNumbers = size.allNumbers
                self.width = !allNumbers.isEmpty ? allNumbers[0] : 0
                self.height = allNumbers.count > 1 ? allNumbers[1] : 0
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

extension String {
    var allNumbers: [Int] {
        
        let numbersInString = components(separatedBy: .decimalDigits.inverted).filter { !$0.isEmpty }
        return numbersInString.compactMap { Int($0) }
    }
}
