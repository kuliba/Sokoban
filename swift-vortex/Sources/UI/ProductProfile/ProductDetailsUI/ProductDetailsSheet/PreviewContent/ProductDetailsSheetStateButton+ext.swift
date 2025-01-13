//
//  ProductDetailsSheetStateButton+ext.swift
//
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import Foundation

extension ProductDetailsSheetState.PanelButton {
    
    static let regularFirstButton: Self = .init(
        event: .sendSelect,
        title: "Отправить выбранные",
        accessibilityIdentifier: "InfoProductSheetTopButton")
    static let regularSecondButton: Self = .init(
        event: .sendAll,
        title: "Отправить все",
        accessibilityIdentifier: "InfoProductSheetBottomButton")
}

extension Array where Element == ProductDetailsSheetState.PanelButton {
    
    public static let previewRegular: Self = [.regularFirstButton, .regularSecondButton]
}
