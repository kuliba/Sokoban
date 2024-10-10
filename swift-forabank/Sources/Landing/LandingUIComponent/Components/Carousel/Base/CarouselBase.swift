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
        
        public struct Size: Equatable {
            
            public let width: CGFloat
            public let height: CGFloat
            
            public init(width: CGFloat, height: CGFloat) {
                self.width = width
                self.height = height
            }
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

extension UILanding.Carousel.CarouselBase {
    
    func action(
        item: Item,
        actions: CarouselActions
    ) -> Action {
        
        switch item.action {
        case .none:
            
            guard let link = item.link else { return {} }
            return { actions.openUrl(link) }
            
        case let .some(action):
            
            if let type = LandingActionType(rawValue: action.type) {
                switch type {
                case .goToMain: return actions.goToMain
                case .orderCard: return {}
                case .goToOrderSticker: return {}
                }
            }
            
            return {}
        }
    }
}

extension UILanding.Carousel.CarouselBase {
    
    typealias Action = () -> Void
    typealias Event = LandingEvent
    typealias Item = UILanding.Carousel.CarouselBase.ListItem
}
