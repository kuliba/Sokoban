//
//  ModifierConfig.swift
//  
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import Foundation

public struct ModifierConfig {
    
    let isChecked: Bool
    let isUpdating: Bool
    let opacity: Double
    let isShowingCardBack: Bool
    let cardWiggle: Bool
    
    let action: () -> Void
    
    public init(
        isChecked: Bool,
        isUpdating: Bool,
        opacity: Double,
        isShowingCardBack: Bool,
        cardWiggle: Bool,
        action: @escaping () -> Void
    ) {
        self.isChecked = isChecked
        self.isUpdating = isUpdating
        self.opacity = opacity
        self.isShowingCardBack = isShowingCardBack
        self.cardWiggle = cardWiggle
        self.action = action
    }
}
