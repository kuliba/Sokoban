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
    let orderSticker: () -> Void
    let orderCard: () -> Void
    let landing: (String?) -> Void
    
    public init(
        openUrl: @escaping (String) -> Void,
        goToMain: @escaping () -> Void,
        orderSticker: @escaping () -> Void,
        orderCard: @escaping () -> Void,
        landing: @escaping (String?) -> Void
    ) {
        self.openUrl = openUrl
        self.goToMain = goToMain
        self.orderSticker = orderSticker
        self.orderCard = orderCard
        self.landing = landing
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
            
        case let (.some(action), _):
            return Self.action(itemAction: action, link: link, actions: actions)
            
        default:
            return {}
        }
    }
    
    private static func action(
        itemAction: ItemAction,
        link: String?,
        actions: CarouselActions
    ) -> () -> Void {
        
        if let type = LandingActionType(rawValue: itemAction.type) {
            switch type {
            case .goToMain: return actions.goToMain
                
            case .goToOrderSticker: return actions.orderSticker
                
            default: return {}
            }
        } else {
            
            switch itemAction.type {
            case "LANDING":
                return { actions.landing(itemAction.target) }
                
            case "cardOrderList":
                return { actions.orderCard() }
                
            default:
                return {
                    guard let link else { return {}() }
                    actions.openUrl(link)
                }
            }
        }
    }
}
