//
//  ProductProfileReducer.swift
//
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import UIPrimitives
import CardGuardianModule

public final class ProductProfileReducer {
    
    public init() {}
}

public extension ProductProfileReducer {
    
#warning("add tests")
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?

        switch event {
        case .closeAlert:
            state.alert = nil
        case .openCardGuardianPanel:
            print("navigation openCardGuardianPanel")
        case .dismissDestination:
            state.modal = nil
        case .showAlertChangePin:
            state.modal = nil
            effect = .delayAlert(alertChangePin())

        case let .showAlertCardGuardian(status):
            state.modal = nil
            effect = .delayAlert(alertBlockCard(status))
        case let .showAlert(alert):
            state.alert = alert
        }
        return (state, effect)
    }
    
    private func alertChangePin(
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
    
    private func alertBlockCard(
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

    private func titleForAlertCardGuardian(
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
    
    private func messageForAlertCardGuardian(
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

    private func titleSecondaryButtonForAlertCardGuardian(
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

public extension ProductProfileReducer {
    
    typealias State = ProductProfileNavigation.State
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Reduce = (State, Event) -> (State, Effect?)
}
