//
//  ShimmeringModifier.swift
//  
//
//  Created by Andryusina Nataly on 29.11.2024.
//

import SwiftUI

struct ShimmeringModifier: ViewModifier {
    
    let needShimmering: Bool
    let color: Color
    
    init(
        _ needShimmering: Bool = false,
        _ color: Color
    ) {
        self.needShimmering = needShimmering
        self.color = color
    }
    
    func body(content: Content) -> some View {
        
        content
            .overlay(needShimmering ? color : .clear)
            .cornerRadius(needShimmering ? 90 : 0)
            .shimmering(active: needShimmering)
    }
}

