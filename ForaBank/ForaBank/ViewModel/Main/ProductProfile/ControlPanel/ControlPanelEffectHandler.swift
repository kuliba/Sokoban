//
//  ControlPanelEffectHandler.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.07.2024.
//

import SwiftUI
import LandingUIComponent

final class ControlPanelEffectHandler {
    
    private let productProfileServices: ProductProfileServices
    
    init(productProfileServices: ProductProfileServices) {
        self.productProfileServices = productProfileServices
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
            
        case let .loadSVCardLanding(cardType):
            
            productProfileServices.createSVCardLanding.createSVCardLanding((serial: "", abroadType: cardType.abroadType)){
                
                result in
                switch result {
                case .failure:
                    break
                case let .success(landing):
                    dispatch(.loadedSVCardLanding(self.productProfileServices.makeSVCardLandingViewModel(
                        landing,
                        .default,
                        {
                            switch $0 {
                            case let .openUrl(link):
                                return {
                                    if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            default:
                                return {}
                            }
                            
                        })))
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
