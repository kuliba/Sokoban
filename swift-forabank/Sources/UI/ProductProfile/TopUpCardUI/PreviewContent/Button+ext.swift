//
//  Button+ext.swift
//
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import Foundation

extension TopUpCardState.PanelButton {
    
    static let regularFirstButton: Self = .init(
        event: .accountOurBank(.regular),
        title: "С моего счета в другом банке",
        iconType: .accountOurBank,
        subtitle: nil)
    static let regularSecondButton: Self = .init(
        event: .accountAnotherBank(.regular),
        title: "Со своего счета",
        iconType: .accountOtherBank,
        subtitle: nil)
    
    static let additionalSelfNotOwnerFirstButton: Self = .init(
        event: .accountOurBank(.additionalSelf),
        title: "С моего счета в другом банке",
        iconType: .accountOurBank,
        subtitle: "Эта услуга доступна только для основной карты")
    static let additionalSelfNotOwnerSecondButton: Self = .init(
        event: .accountAnotherBank(.additionalSelf),
        title: "Со своего счета",
        iconType: .accountOtherBank,
        subtitle: "Эта услуга доступна только владельцу карты")
    
    static let additionalOtherFirstButton: Self = .init(
        event: .accountOurBank(.additionalOther),
        title: "С моего счета в другом банке",
        iconType: .accountOurBank,
        subtitle: nil)
    static let additionalOtherSecondButton: Self = .init(
        event: .accountAnotherBank(.additionalOther),
        title: "Со своего счета",
        iconType: .accountOtherBank,
        subtitle: "Эта услуга доступна только владельцу карты")
}

extension Array where Element == TopUpCardState.PanelButton {
    
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
