//
//  Button+ext.swift
//  
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import Foundation

extension CardGuardianState._Button {
    
    static let one: Self = .init(
        event: .toggleLock(.active),
        title: "Блокировать",
        iconType: .toggleLock,
        subtitle: nil)
    static let two: Self = .init(
        event: .changePin,
        title: "Изменить PIN-код",
        iconType: .changePin,
        subtitle: nil)
    static let three: Self = .init(
        event: .showOnMain,
        title: "Скрыть с главного",
        iconType: .showOnMain,
        subtitle: "Карта не будет отображаться на главном экране")
    
    static let cardBlocked: Self = .init(
        event: .toggleLock(.blockedUnlockAvailable),
        title: "Разблокировать",
        iconType: .toggleLock,
        subtitle: nil)
    
    static let cardBlockedUnlockNotAvailable: Self = .init(
        event: .toggleLock(.blockedUnlockNotAvailable),
        title: "Разблокировать",
        iconType: .toggleLock,
        subtitle: nil)

    static let cardHidden: Self = .init(
        event: .showOnMain,
        title: "Вернуть на главный",
        iconType: .showOnMain,
        subtitle: "Карта будет отображаться на главном экране")
}

extension Array where Element == CardGuardianState._Button {
    
    public static let preview: Self = [.one, .two, .three]
    public static let previewBlockHide: Self = [.cardBlocked, .two, .cardHidden]
    public static let previewBlockUnlockNotAvailable: Self = [.cardBlockedUnlockNotAvailable, .two, .cardHidden]
}
