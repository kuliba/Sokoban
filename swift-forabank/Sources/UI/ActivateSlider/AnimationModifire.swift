//
//  AnimationModifire.swift
//  
//
//  Created by Andryusina Nataly on 27.02.2024.
//

import SwiftUI

struct AnimationModifire: ViewModifier {
    
    let isAnimated: Bool
    
    @State var isAnimationStarted: Bool = false
    
    var animation: Animation { Animation.linear(duration: 1.0).repeatForever(autoreverses: false) }
    
    func body(content: Content) -> some View {
        
        if isAnimated {
            
            content
                .rotationEffect(Angle.degrees(isAnimationStarted ? 360 : 0))
                .animation(animation)
                .onAppear{ isAnimationStarted = true }
        } else { content }
    }
}
