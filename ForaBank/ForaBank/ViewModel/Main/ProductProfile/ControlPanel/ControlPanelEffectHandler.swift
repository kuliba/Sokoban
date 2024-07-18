//
//  ControlPanelEffectHandler.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.07.2024.
//

import SwiftUI
import LandingUIComponent
import LandingMapping

final class ControlPanelEffectHandler {
    
    private let productProfileServices: ProductProfileServices
    private let landingEvent: (LandingEvent) -> Void
    
    init(
        productProfileServices: ProductProfileServices,
        landingEvent: @escaping (LandingEvent) -> Void
    ) {
        self.productProfileServices = productProfileServices
        self.landingEvent = landingEvent
    }
}

extension ControlPanelEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delayAlert(alert, dispatchTimeInterval):
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                
                dispatch(.controlButtonEvent(.showAlert(alert)))
            }
            
        case let .blockCard(card):
            
            productProfileServices.createBlockCardService.createBlockCard(.init(cardId: .init(card.cardId), cardNumber: .init(card.number ?? ""))) { result in
                switch result {
                case .failure:
                    break
                case .success:
                    dispatch(.updateProducts)
                }
            }
            
        case let .unblockCard(card):
            
            productProfileServices.createUnblockCardService.createUnblockCard(.init(cardId: .init(card.cardId), cardNumber: .init(card.number ?? ""))) { result in
                switch result {
                case .failure:
                    break
                case .success:
                    dispatch(.updateProducts)
                }
            }
            
        case let .visibility(card):
            
            productProfileServices.createUserVisibilityProductsSettingsService.createUserVisibilityProductsSettings(.init(category: .card, products: [.init(productID: .init(card.id), visibility: .init(!card.isVisible))])) { result in
                switch result {
                case .failure:
                    break
                case .success:
                    dispatch(.updateProducts)
                }
            }
            
        case let .loadSVCardLanding(card):
            let cardType = card.cardType ?? .regular
            
            productProfileServices.createSVCardLanding.createSVCardLanding((serial: "", abroadType: cardType.abroadType)){
                
                result in
                switch result {
                case .failure:
                    dispatch(.loadedSVCardLanding(nil, card))
                    
                case let .success(landing):
                    
                    let limitsVM: ListHorizontalRectangleLimitsViewModel? = {
                        
                        if let limits = landing.horizontalRectangleLimits {
                            
                            return .init(
                                initialState: .init(list: .init(limits), limitsLoadingStatus: .inflight),
                                reduce: ListHorizontalRectangleLimitsReducer.init().reduce(_:_:),
                                handleEffect: {_,_ in })
                        }
                        return nil
                    }()
                    
                    dispatch(.loadedSVCardLanding(self.productProfileServices.makeSVCardLandingViewModel(
                        landing,
                        limitsVM,
                        .default,
                        self.landingEvent
                    ), card))
                }
            }
            
        case let .loadSVCardLimits(card):
            productProfileServices.createCreateGetSVCardLimits.createGetSVCardLimits(.init(cardId: card.cardId)){
                
                result in
                switch result {
                case .failure:
                    dispatch(.loadedSVCardLimits(nil))
                case let .success(limitsResponse):
                    dispatch(.loadedSVCardLimits(.some(limitsResponse.limitsList)))
                }
            }
        }
    }
}

extension ControlPanelEffectHandler {
    
    typealias Event = ControlPanelEvent
    typealias Effect = ControlPanelEffect
    typealias Dispatch = (Event) -> Void
}

private extension UILanding.List.HorizontalRectangleLimits {
    
    init(
        _ data: Landing.DataView.List.HorizontalRectangleLimits
    ) {
        self.init(list: data.list.map { .init($0) })
    }
}

private extension UILanding.List.HorizontalRectangleLimits.Item {
    
    init(
        _ data: Landing.DataView.List.HorizontalRectangleLimits.Item
    ) {
        
        self.init(action: .init(type: data.action.type), limitType: data.limitType, md5hash: data.md5hash, title: data.title, limits: data.limits.map { .init($0) })
    }
}

private extension UILanding.List.HorizontalRectangleLimits.Item.Limit {
    
    init(
        _ data: Landing.DataView.List.HorizontalRectangleLimits.Item.Limit
    ) {
        
        self.init(id: data.id, title: data.title, color: .init(hex: data.colorHEX))
    }
}
