//
//  Button+ext.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import Foundation

extension AccountInfoPanelState.PanelButton {
    
    static let regularFirstButton: Self = .init(
        event: .accountDetails(.regular),
        title: "Реквизиты счета карты",
        iconType: .accountDetails,
        subtitle: nil)
    static let regularSecondButton: Self = .init(
        event: .accountStatement(.regular),
        title: "Выписка по счету",
        iconType: .accountStatement,
        subtitle: nil)
    
    static let additionalSelfNotOwnerFirstButton: Self = .init(
        event: .accountDetails(.additionalSelf),
        title: "Реквизиты счета карты",
        iconType: .accountDetails,
        subtitle: nil)
    static let additionalSelfNotOwnerSecondButton: Self = .init(
        event: .accountStatement(.additionalSelf),
        title: "Выписка по счету",
        iconType: .accountStatement,
        subtitle: "Выписку может заказать владелец основной карты и счета")
    
    static let additionalOtherFirstButton: Self = .init(
        event: .accountDetails(.additionalOther),
        title: "Реквизиты счета карты",
        iconType: .accountDetails,
        subtitle: nil)
    static let additionalOtherSecondButton: Self = .init(
        event: .accountStatement(.additionalOther),
        title: "Выписка по счету",
        iconType: .accountStatement,
        subtitle: "Выписку может заказать владелец основной карты и счета")
}

extension Array where Element == AccountInfoPanelState.PanelButton {
    
    public static let previewRegular: Self = [.regularFirstButton, .regularSecondButton]
    public static let previewAdditionalSelfNotOwner: Self = [.additionalSelfNotOwnerFirstButton, .additionalSelfNotOwnerSecondButton]
    public static let previewAdditionalOther: Self = [.additionalOtherFirstButton, .additionalOtherSecondButton]
}

extension Card {
    
    static let regular: Self = .init(
        cardId: 1,
        cardNumber: "1",
        cardStatus: .regular)
    
    static let additionalSelf: Self = .init(
        cardId: 2,
        cardNumber: "2",
        cardStatus: .additionalSelf)

    static let additionalOther: Self = .init(
        cardId: 3,
        cardNumber: "3",
        cardStatus: .additionalOther)
}
