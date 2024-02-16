//
//  Button+ext.swift
//  
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import Foundation

extension CardGuardianState._Button {
    
    static let one: Self = .init(
        event: .toggleLock(.cardActive),
        title: "Блокировать",
        iconType: .toggleLock,
        subtitle: nil)
    static let two: Self = .init(
        event: .changePin(.cardActive),
        title: "Изменить PIN-код",
        iconType: .changePin,
        subtitle: nil)
    static let three: Self = .init(
        event: .toggleVisibilityOnMain(.init(productID: 11, visibility: false)),
        title: "Скрыть с главного",
        iconType: .showOnMain,
        subtitle: "Карта не будет отображаться на главном экране")
    
    static let cardBlocked: Self = .init(
        event: .toggleLock(.cardBlockedUnlockAvailable),
        title: "Разблокировать",
        iconType: .toggleLock,
        subtitle: nil)
    
    static let cardBlockedUnlockNotAvailable: Self = .init(
        event: .toggleLock(.cardblockedUnlockNotAvailable),
        title: "Разблокировать",
        iconType: .toggleLock,
        subtitle: nil)

    static let cardHidden: Self = .init(
        event: .toggleVisibilityOnMain(.init(productID: 11, visibility: true)),
        title: "Вернуть на главный",
        iconType: .showOnMain,
        subtitle: "Карта будет отображаться на главном экране")
}

extension Array where Element == CardGuardianState._Button {
    
    public static let preview: Self = [.one, .two, .three]
    public static let previewBlockHide: Self = [.cardBlocked, .two, .cardHidden]
    public static let previewBlockUnlockNotAvailable: Self = [.cardBlockedUnlockNotAvailable, .two, .cardHidden]
}

extension Card {
    
    static let cardActive: Self = .init(cardId: 1, cardNumber: "111", cardGuardianStatus: .active)
    
    static let cardBlockedUnlockAvailable: Self = .init(cardId: 1, cardNumber: "111", cardGuardianStatus: .blockedUnlockAvailable)

    static let cardblockedUnlockNotAvailable: Self = .init(cardId: 1, cardNumber: "111", cardGuardianStatus: .blockedUnlockNotAvailable)
}
