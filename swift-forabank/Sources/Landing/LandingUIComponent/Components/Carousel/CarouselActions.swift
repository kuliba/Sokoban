//
//  CarouselActions.swift
//  
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import Foundation

public struct CarouselActions {
    
    let openUrl: (String) -> Void
    let goToMain: () -> Void
    
    public init(
        openUrl: @escaping (String) -> Void,
        goToMain: @escaping () -> Void
    ) {
        self.openUrl = openUrl
        self.goToMain = goToMain
    }
}

extension UILanding.Carousel {
    
    static func action(
        itemAction: ItemAction?,
        link: String?,
        actions: CarouselActions
    ) -> () -> Void {
        
        switch(itemAction, link) {
        case let (.none, .some(link)):
            return { actions.openUrl(link) }
            
        case let (.some(action), .some(link)):
            
            if let type = LandingActionType(rawValue: action.type) {
                switch type {
                case .goToMain: return actions.goToMain
                case .orderCard: return {}
                case .goToOrderSticker: return {}
                }
            } else { return { actions.openUrl(link) }}
            
        default:
            return {}
        }
    }
}
