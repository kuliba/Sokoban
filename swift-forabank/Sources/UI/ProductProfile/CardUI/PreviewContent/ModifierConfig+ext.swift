//
//  ModifierConfig+ext.swift
//
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import Foundation

extension ModifierConfig {
    
    static let previewUpdating: Self = .init(
        isChecked: false,
        isUpdating: true,
        opacity: 1,
        isShowingCardBack: false,
        cardWiggle: false,
        action: { print("action") }
    )
    
    static let previewChecked: Self = .init(
        isChecked: true,
        isUpdating: false,
        opacity: 1,
        isShowingCardBack: false,
        cardWiggle: false,
        action: { print("action") }
    )
    
    static let previewFront: Self = .init(
        isChecked: false,
        isUpdating: false,
        opacity: 1,
        isShowingCardBack: false,
        cardWiggle: false,
        action: { print("action") }
    )
    
    static let previewBack: Self = .init(
        isChecked: false,
        isUpdating: false,
        opacity: 1,
        isShowingCardBack: true,
        cardWiggle: false,
        action: { print("action") }
    )
}
