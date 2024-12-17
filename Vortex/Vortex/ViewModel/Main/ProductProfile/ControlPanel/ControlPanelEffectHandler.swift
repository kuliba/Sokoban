//
//  ControlPanelEffectHandler.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.07.2024.
//

import SwiftUI
import LandingUIComponent
import LandingMapping
import SVCardLimitAPI
import RemoteServices

final class ControlPanelEffectHandler {
    
    private let handleModelEffect: HandleModelEffect
    private let productProfileServices: ProductProfileServices
    private let landingEvent: (LandingEvent) -> Void
    private let card: ProductCardData
    private let hideKeyboard: () -> Void
    private let getCurrencySymbol: GetCurrencySymbol

    init(
        card: ProductCardData,
        productProfileServices: ProductProfileServices,
        landingEvent: @escaping (LandingEvent) -> Void,
        handleModelEffect: @escaping HandleModelEffect,
        hideKeyboard: @escaping () -> Void,
        getCurrencySymbol: @escaping GetCurrencySymbol
    ) {
        self.card = card
        self.productProfileServices = productProfileServices
        self.landingEvent = landingEvent
        self.handleModelEffect = handleModelEffect
        self.hideKeyboard = hideKeyboard
        self.getCurrencySymbol = getCurrencySymbol
    }
}

extension ControlPanelEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case let .model(modelEffect):
            handleModelEffect(modelEffect, dispatch)

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
            
            productProfileServices.createSVCardLanding.createSVCardLanding((serial: "", abroadType: cardType.controlAbroadType)){
                
                result in
                switch result {
                case .failure:
                    dispatch(.loadedSVCardLanding(nil, card))
                    
                case let .success(landing):
                    
                    let limitsVM: ListHorizontalRectangleLimitsViewModel? = {
                        
                        if let limits = landing.horizontalRectangleLimits {
                            
                            return .init(
                                initialState: .init(list: .init(limits), limitsLoadingStatus: .inflight(.loadingSVCardLimits)),
                                reduce: ListHorizontalRectangleLimitsReducer.init(
                                    makeInformer: self.productProfileServices.makeInformer,
                                    getCurrencySymbol: self.getCurrencySymbol)
                                .reduce(_:_:),
                                handleEffect: self.handleEffect(_:_:))
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
    
    typealias HandleModelEffect = (Effect.ModelEffect, @escaping Dispatch) -> Void
    typealias GetCurrencySymbol = (Int) -> String?
}

private extension ControlPanelEffectHandler {
    
    func handleEffect(
        _ effect: LimitsEffect,
        _ dispatch: @escaping LimitsDispatch
    ) {
        switch effect {
        case let .loadSVCardLanding(limitType):
            
            let cardType = card.cardType ?? .regular
            
            productProfileServices.createSVCardLanding.createSVCardLanding((serial: "", abroadType: cardType.limitAbroadType)){
                
                result in
                switch result {
                case .failure:
                    dispatch(.loadedLimits(nil, "", limitType))
                    
                case let .success(landing):
                                        
                    dispatch(.loadedLimits(self.productProfileServices.makeSVCardLandingViewModel(
                        landing,
                        nil,
                        .default,
                        self.landingEvent
                    ),  self.card.navigationTitleForControlPanel, limitType))
                }
            }
            
        case let .saveLimits(limits):
                hideKeyboard()
            
            DispatchQueue.global(qos: .userInitiated).delay(for: .milliseconds(100)) { [weak self] in
                
                guard let self else { return }
                
                productProfileServices.createChangeSVCardLimit.сhangeSVCardLimits(card: card, payloads: limits.payloads(card.cardId)) {
                    
                    switch ($0, $1) {
                        
                    case let (.some(text), nil):
                        dispatch(.delayAlert(text))
                        
                    case let (.none, .some(limits)):
                        
                        dispatch(.informerWithLimits("Лимиты установлены", limits))
                    default:
                        break
                    }
                }
            }
            
        case let .showAlert(message, interval):
            
            DispatchQueue.main.delay(for: interval) {
                
                dispatch(.showAlert(message))
            }
        }
    }

    typealias LimitsEvent = ListHorizontalRectangleLimitsEvent
    typealias LimitsEffect = ListHorizontalRectangleLimitsEffect
    typealias LimitsDispatch = (LimitsEvent) -> Void
}

private extension ChangeSVCardLimitPayload {
    
    init(
        _ cardId: Int,
        _ data: BlockHorizontalRectangularEvent.Limit
    ) {
        self.init(cardId: cardId, limit: .init(name: data.id, value: data.value))
    }
}

private extension Array where Element ==  BlockHorizontalRectangularEvent.Limit {
    
    func payloads(_ cardId: ProductData.ID) -> [ChangeSVCardLimitPayload] {
        
        map {
            .init(cardId, $0)
        }
    }
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
