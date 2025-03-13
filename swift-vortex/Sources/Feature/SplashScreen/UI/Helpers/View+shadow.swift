//
//  View+shadow.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

// TODO: - move to UIPrimitives
extension View {
    
    func shadow(_ shadow: Shadow) -> some View {
        
        self.shadow(
            color: shadow.color.opacity(shadow.opacity),
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

struct Shadow: Equatable {
    
    let color: Color
    let opacity: Double
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
