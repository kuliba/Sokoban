//
//  AlertModelOf+ext.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import UIPrimitives
import CardGuardianUI
import Foundation

public extension AlertModelOf<ProductProfileNavigation.Event> {
    
    static func alertBlockCard(
        _ card: Card,
        _ id: UUID = .init()
    ) -> AlertModelOf<ProductProfileNavigation.Event> {
        
        .init(
            id: id,
            title: titleForAlertCardGuardian(card),
            message: messageForAlertCardGuardian(card),
            primaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .closeAlert),
            secondaryButton: .init(
                type: .default,
                title: titleSecondaryButtonForAlertCardGuardian(card),
                event: event(card))
        )
    }
    
    private static func titleForAlertCardGuardian(
        _ card: Card
    ) -> String {
        
        switch card.status {
        case .active:
            return "Заблокировать карту?"
        case .blockedUnlockAvailable:
            return "Разблокировать карту?"
        case .blockedUnlockNotAvailable:
            return "Невозможно разблокировать"
        case .notActivated:
            return ""
        }
    }
    
    private static func messageForAlertCardGuardian(
        _ card: Card
    ) -> String? {
        
        switch card.status {
        case .active:
            return "Карту можно будет разблокировать в приложении или в колл-центре"
        case .blockedUnlockAvailable:
            return .none
        case .blockedUnlockNotAvailable:
            return "Обратитесь в поддержку, чтобы разблокировать карту"
        case .notActivated:
            return .none
        }
    }
    
    private static func titleSecondaryButtonForAlertCardGuardian(
        _ card: Card
    ) -> String {
        
        switch card.status {
        case .active:
            return "ОК"
        case .blockedUnlockAvailable:
            return "Да"
        case .blockedUnlockNotAvailable:
            return "Контакты"
        case .notActivated:
            return ""
        }
    }
    
    private static func event(
        _ card: Card
    ) -> ProductProfileNavigation.Event {
        
        switch card.status {
        case .active, .blockedUnlockAvailable:
            return .productProfile(.guardCard(card))
        case .blockedUnlockNotAvailable:
            return .productProfile(.showContacts)
        case .notActivated:
            return .closeAlert
        }
    }
    
    static func alertCVV(
        _ id: UUID = .init()
    ) -> AlertModelOf<ProductProfileNavigation.Event> {
        
        .init(
            id: id,
            title: "Информация",
            message: "CVV может увидеть только человек,\nна которого выпущена карта.\nЭто мера предосторожности во избежание мошеннических операций.",
            primaryButton: .init(
                type: .cancel,
                title: "OK",
                event: .closeAlert))
    }
    
    static func alertCardBlocked(
        _ id: UUID = .init()
    ) -> AlertModelOf<ProductProfileNavigation.Event> {
        
        .init(
            id: id,
            title: "Информация",
            message: "Для просмотра CVV и смены PIN карта должна быть активна.",
            primaryButton: .init(
                type: .cancel,
                title: "OK",
                event: .closeAlert))
    }
}
