//
//  Alerts.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import UIPrimitives
import CardGuardianModule

struct Alerts {}

extension Alerts {
    
    static func alertChangePin(
    ) -> AlertModelOf<ProductProfileNavigation.Event> {
        
        .init(
            title: "Активируйте сертификат",
            message: "\nСертификат позволяет просматривать CVV по картам и изменять PIN-код\nв течение 6 месяцев\n\nЭто мера предосторожности во избежание мошеннических операций",
            primaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .closeAlert),
            secondaryButton: .init(
                type: .default,
                title: "Активировать",
                event: .closeAlert)
        )
    }
    
    static func alertBlockCard(
        _ status: CardGuardian.CardGuardianStatus
    ) -> AlertModelOf<ProductProfileNavigation.Event> {
        
        .init(
            title: titleForAlertCardGuardian(status),
            message: messageForAlertCardGuardian(status),
            primaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .closeAlert),
            secondaryButton: .init(
                type: .default,
                title: titleSecondaryButtonForAlertCardGuardian(status),
                event: .closeAlert)
        )
    }
    
    private static func titleForAlertCardGuardian(
        _ status: CardGuardian.CardGuardianStatus
    ) -> String {
        
        switch status {
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
        _ status: CardGuardian.CardGuardianStatus
    ) -> String? {
        
        switch status {
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
        _ status: CardGuardian.CardGuardianStatus
    ) -> String {
        
        switch status {
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
}
