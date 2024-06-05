//
//  View+Shimmering.swift
//  
//
//  Created by Andryusina Nataly on 19.09.2023.
//

import SwiftUI
import Shimmer

//TODO: move to UIPrimitives and replace Landing shimmering

public extension View {
    
    func shimmering(
        duration: Double = 1.5,
        bounce: Bool = false
    ) -> some View {
    
        self.modifier(Shimmering(bounce: bounce, duration: duration))
    }
}

struct Shimmering: ViewModifier {
    
    let bounce: Bool
    let duration: Double
    
    func body(content: Content) -> some View {
        
        content
            .shimmering(duration: duration, bounce: bounce)
    }
}
