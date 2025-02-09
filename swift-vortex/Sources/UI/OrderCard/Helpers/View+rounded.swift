//
//  View+rounded.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SwiftUI

extension View {
    
    func rounded(
        background: Color,
        cornerRadius: CGFloat,
        padding: CGFloat
    ) -> some View {
        
        modifier(
            ViewWithBackgroundCornerRadiusAndPaddingModifier(
                background: background,
                cornerRadius: cornerRadius,
                padding: padding
            )
        )
    }
}
