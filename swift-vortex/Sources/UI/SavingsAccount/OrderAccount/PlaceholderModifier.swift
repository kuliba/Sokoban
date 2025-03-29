//
//  PlaceholderModifier.swift
//  swift-vortex
//
//  Created by Andryusina Nataly on 29.03.2025.
//

import SwiftUI

struct PlaceholderModifier: ViewModifier {
    
    let colors: Colors
    let cornerRadius: CGFloat
    let isFailure: Bool
    let isLoading: Bool
    
    struct Colors {
        let placeholder: Color
        let shimmering: Color
    }
    
    func body(content: Content) -> some View {
        
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isFailure ? colors.placeholder : .clear)
            .modifier(ShimmeringModifier(isLoading, colors.shimmering))
            .cornerRadius(cornerRadius)
    }
}
