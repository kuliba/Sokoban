//
//  ViewWithBackgroundCornerRadiusAndPaddingModifier.swift
//
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import SwiftUI

public struct ViewWithBackgroundCornerRadiusAndPaddingModifier: ViewModifier {
    
    public let background: Color
    public let cornerRadius: CGFloat
    public let padding: CGFloat
    
    public init(_ background: Color, _ cornerRadius: CGFloat, _ padding: CGFloat) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(.all, padding)
            .background(background)
            .cornerRadius(cornerRadius)
    }
}
