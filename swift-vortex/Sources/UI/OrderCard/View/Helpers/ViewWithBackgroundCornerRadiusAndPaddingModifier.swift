//
//  ViewWithBackgroundCornerRadiusAndPaddingModifier.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import SwiftUI

struct ViewWithBackgroundCornerRadiusAndPaddingModifier: ViewModifier {
    
    let background: Color
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(
        background: Color,
        cornerRadius: CGFloat,
        padding: CGFloat
    ) {
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
