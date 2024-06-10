//
//  View+Shimmering.swift
//
//
//  Created by Дмитрий Савушкин on 05.06.2024.
//

import SwiftUI
import Shimmer

public extension View {
    
    func shimmering(
        active: Bool = true,
        bounce: Bool = false,
        duration: Double = 1.5
    ) -> some View {
    
        self.modifier(Shimmering(active: active, bounce: bounce, duration: duration))
    }
}

struct Shimmering: ViewModifier {
    
    let active: Bool
    let bounce: Bool
    let duration: Double
    
    func body(content: Content) -> some View {
        
        content
            .shimmering(active: active, duration: duration, bounce: bounce)
    }
}
