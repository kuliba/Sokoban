//
//  ProductProfileViewModel+createCardGuardianPanel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.04.2024.
//

import SwiftUI

extension ProductProfileViewModel {
    
    func createCardGuardianPanel(_ card: ProductCardData) {
        
        let buttons: [PanelButton.Details] = {
            
            switch card.cardType {
            case .additionalOther:
                return [
                    .createCardGuardianButton(by: card),
                    .createVisibilityButton(by: card)
                ]
            default:
                if card.statusCard == .blockedUnlockNotAvailable {
                    return [.createVisibilityButton(by: card)]
                } else {
                    return [
                        .createCardGuardianButton(by: card),
                        .createChangePinButton(by: card),
                        .createVisibilityButton(by: card)
                    ]
                }
            }
        }()
        bottomSheet = .init(type: .optionsPanelNew(buttons))
    }
}

private extension String {
    
    static func cardGuardianTitle(by status: ProductCardData.StatusCard?) -> String {
        switch status {
        case .blockedUnlockAvailable:
            return "Разблокировать"
        case .active:
            return "Заблокировать"
        default:
            return ""
        }
    }
    
    static func changePinTitle() -> String {
        return "Изменить PIN-код"
    }
    
    static func visibilityTitle(by visibility: Bool) -> String {
        return visibility ? "Скрыть с главного" : "Вернуть на главный"
    }
    
    static func visibilitySubtitle(by visibility: Bool) -> String {
        
        return visibility
        ? "Карта не будет отображаться на главном экране"
        : "Карта будет отображаться на главном экране"
    }
}

private extension Image {
    
    static func cardGuardian(by cardGuardianStatus: ProductCardData.StatusCard?) -> Image? {
        
        switch cardGuardianStatus {
        case .active:
            return .ic24Lock
        case .blockedUnlockAvailable:
            return .ic24Unlock
        default:
            return .none
        }
    }
    
    static func visibility(by visibility: Bool) -> Image {
        
        return visibility ? .ic24EyeOff : .ic24Eye
    }
}

private extension PanelButton.Details {
    
    static func createCardGuardianButton(by card: ProductCardData) -> Self {
        
        return .init(
            ID: card.id,
            title: .cardGuardianTitle(by: card.statusCard),
            icon: .cardGuardian(by: card.statusCard),
            subtitle: nil,
            kind: .cardGuardian)
    }
    
    static func createVisibilityButton(by card: ProductCardData) -> Self {
        
        return .init(
            ID: card.id,
            title: .visibilityTitle(by: card.isVisible),
            icon: .visibility(by: card.isVisible),
            subtitle: .visibilitySubtitle(by: card.isVisible),
            kind: .visibility)
    }
    
    static func createChangePinButton(by card: ProductCardData) -> Self {
        
        return .init(
            ID: card.id,
            title: .changePinTitle(),
            icon: .ic24Pass,
            subtitle: nil,
            kind: .changePin)
    }
}
