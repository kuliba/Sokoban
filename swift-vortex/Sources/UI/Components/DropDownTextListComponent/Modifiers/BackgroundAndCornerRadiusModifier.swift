//
//  BackgroundAndCornerRadiusModifier.swift
//
//
//  Created by Valentin Ozerov on 06.12.2024.
//

import SwiftUI

struct BackgroundAndCornerRadiusModifier: ViewModifier {
    
    let background: Color
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(background)
            .cornerRadius(cornerRadius)
    }
}
