//
//  CarouselWithDotsState.swift
//
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import Foundation

public struct CarouselWithDotsState: Equatable {
    
    let data: UILanding.Carousel.CarouselWithDots
    
    public init(
        data: UILanding.Carousel.CarouselWithDots
    ) {
        self.data = data
    }
    
    // TODO: add other case
    func action(
        item: Item,
        event: @escaping (Event) -> Void
    ) -> Action {
        
        switch item.action {
        case .none:
            
            guard let link = item.link else { return {} }
            return { event(.card(.openUrl(link))) }
            
        case let .some(action):
            
            if let type = LandingActionType(rawValue: action.type) {
                switch type {
                case .goToMain: return { event(.card(.goToMain)) }
                case .orderCard: return {}
                case .goToOrderSticker: return { event(.bannerAction(.landing)) }
                }
            }
            
            return {}
        }
    }
}

extension CarouselWithDotsState {
    
    typealias Action = () -> Void
    typealias Event = LandingEvent
    typealias Item = UILanding.Carousel.CarouselWithDots.ListItem
}
