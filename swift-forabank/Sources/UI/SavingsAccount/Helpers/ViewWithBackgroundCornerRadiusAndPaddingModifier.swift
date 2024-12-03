//
//  ViewWithBackgroundCornerRadiusAndPaddingModifier.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//

import SwiftUI

struct ViewWithBackgroundCornerRadiusAndPaddingModifier: ViewModifier {
    
    let background: Color
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(_ background: Color, _ cornerRadius: CGFloat, _ padding: CGFloat) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.all, padding)
            .background(background)
            .cornerRadius(cornerRadius)
    }
}

