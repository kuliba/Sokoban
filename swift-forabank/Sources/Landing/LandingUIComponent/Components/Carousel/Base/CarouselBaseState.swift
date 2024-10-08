//
//  CarouselBaseState.swift
//
//
//  Created by Andryusina Nataly on 05.10.2024.
//

import Foundation

public struct CarouselBaseState: Equatable {
    
    let data: UILanding.Carousel.CarouselBase
    
    public init(
        data: UILanding.Carousel.CarouselBase
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

extension CarouselBaseState {
    
    typealias Action = () -> Void
    typealias Event = LandingEvent
    typealias Item = UILanding.Carousel.CarouselBase.ListItem
}
