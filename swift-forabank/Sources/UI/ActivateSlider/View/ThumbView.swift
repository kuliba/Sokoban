//
//  ThumbView.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

struct ThumbView: View {
    
    let config: ThumbConfig
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(config.backgroundColor)
                .frame(width: 40, height: 40)
            
            config.icon
                .resizable()
                .renderingMode(.template)
                .foregroundColor(config.color)
                .frame(width: 24, height: 24)
                .modifier(AnimationModifire(isAnimated: config.isAnimated))
        }
    }
}

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
