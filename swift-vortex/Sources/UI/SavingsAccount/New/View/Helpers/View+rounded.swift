//
//  View+rounded.swift
//
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import SwiftUI

extension View {
    
    func rounded(
        _ config: RoundedConfig
    ) -> some View {
        
        modifier(
            ViewWithBackgroundCornerRadiusAndPaddingModifier(
                config.background,
                config.cornerRadius,
                config.padding
            )
        )
    }
    
    func rounded(
        background: Color,
        cornerRadius: CGFloat,
        padding: CGFloat
    ) -> some View {
        
        modifier(
            ViewWithBackgroundCornerRadiusAndPaddingModifier(
                background,
                cornerRadius,
                padding
            )
        )
    }
}
