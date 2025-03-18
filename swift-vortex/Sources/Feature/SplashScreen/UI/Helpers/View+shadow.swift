//
//  View+shadow.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

// TODO: - move to UIPrimitives??
extension View {
    
    func shadow(
        _ shadow: SplashScreenState.Settings.Shadow
    ) -> some View {
        
        self.shadow(
            color: shadow.color.opacity(shadow.opacity),
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}
