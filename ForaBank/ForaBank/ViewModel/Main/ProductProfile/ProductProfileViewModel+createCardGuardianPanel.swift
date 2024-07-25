//
//  ProductProfileViewModel+createCardGuardianPanel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.04.2024.
//

import SwiftUI

extension ProductProfileViewModel {
    
    enum PanelButtonType {
        case block, unblock, changePin, visibility
    }
}

private extension String {
    
    static func cardGuardianTitle(
        by status: ProductCardData.StatusCard?,
        _ flag: ChangeSVCardLimitsFlag
    ) -> String {
        switch status {
        case .blockedUnlockAvailable, .blockedUnlockNotAvailable:
            return  flag.isActive ? "Разблок. карту" : "Разблокировать"
        case .active:
            return flag.isActive ? "Блокировать карту" : "Блокировать"
        default:
            return ""
        }
    }
    
    static func changePinTitle() -> String {
        return "Изменить PIN-код"
    }
    
    static func visibilityTitle(
        by visibility: Bool,
        _ flag: ChangeSVCardLimitsFlag = .init(.inactive)
    ) -> String {
        return visibility ? (flag.isActive ? "Скрыть\nс главного" : "Скрыть с главного") : "Вернуть на главный"
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
        case .blockedUnlockAvailable, .blockedUnlockNotAvailable:
            return .ic24Unlock
        default:
            return .none
        }
    }
    
    static func visibility(by visibility: Bool) -> Image {
        
        return visibility ? .ic24EyeOff : .ic24Eye
    }
}

private extension PanelButtonDetails {
    
    static func createCardGuardianButton(by card: ProductCardData, _ flag: ChangeSVCardLimitsFlag) -> Self {
        
        return .init(
            id: card.id,
            title: .cardGuardianTitle(by: card.statusCard, flag),
            icon: .cardGuardian(by: card.statusCard),
            subtitle: nil,
            kind: .cardGuardian)
    }
    
    static func createVisibilityButton(by card: ProductCardData) -> Self {
        
        return .init(
            id: card.id,
            title: .visibilityTitle(by: card.isVisible),
            icon: .visibility(by: card.isVisible),
            subtitle: .visibilitySubtitle(by: card.isVisible),
            kind: .visibility)
    }
    
    static func createChangePinButton(by card: ProductCardData) -> Self {
        
        return .init(
            id: card.id,
            title: .changePinTitle(),
            icon: .ic24Pass,
            subtitle: nil,
            kind: .changePin)
    }
}

extension Array where Element == PanelButtonDetails {
    
    static func cardGuardian(
        _ card: ProductCardData,
        _ flag: ChangeSVCardLimitsFlag
    ) -> Self {
        
        switch card.cardType {
        case .additionalOther:
            return [
                .createCardGuardianButton(by: card, flag),
                .createVisibilityButton(by: card)
            ]
        default:
            return [
                .createCardGuardianButton(by: card, flag),
                .createChangePinButton(by: card),
                .createVisibilityButton(by: card)
            ]
        }
    }
}

private extension ControlPanelButtonDetails {
    
    static func createCardGuardianButton(
        by card: ProductCardData,
        _ flag: ChangeSVCardLimitsFlag
    ) -> Self {
        
        return .init(
            id: card.id,
            title: .cardGuardianTitle(by: card.statusCard, flag),
            icon: .cardGuardian(by: card.statusCard),
            event: .delayAlert(card))
    }
    
    static func createVisibilityButton(
        by card: ProductCardData,
        _ flag: ChangeSVCardLimitsFlag
    ) -> Self {
        
        return .init(
            id: card.id,
            title: .visibilityTitle(by: card.isVisible, flag),
            icon: .visibility(by: card.isVisible),
            event: .visibility(card))
    }
    
    static func createChangePinButton(by card: ProductCardData) -> Self {
        
        return .init(
            id: card.id,
            title: .changePinTitle(),
            icon: .ic24Pass,
            event: .changePin(card))
    }
}

extension Array where Element == ControlPanelButtonDetails {
    
    static func cardGuardian(
        _ card: ProductCardData,
        _ flag: ChangeSVCardLimitsFlag
    ) -> Self {
        
        switch card.cardType {
        case .additionalOther:
            return [
                .createCardGuardianButton(by: card, flag),
                .createVisibilityButton(by: card, flag)
            ]
        default:
            return [
                .createCardGuardianButton(by: card, flag),
                .createVisibilityButton(by: card, flag),
                .createChangePinButton(by: card)
            ]
        }
    }
}
