//
//  AnimatedDotView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct AnimatedDotView: View {
    
    let color: Color
    let size: CGFloat
    let duration: TimeInterval
    let delay: TimeInterval
    @State private var isAnimated: Bool
    
    public init(
        color: Color = .white,
        size: CGFloat = 3.0,
        duration: TimeInterval = 1.0,
        delay: TimeInterval = 0,
        isAnimated: Bool = false
    ) {
        self.color = color
        self.size = size
        self.duration = duration
        self.delay = delay
        self.isAnimated = isAnimated
    }
    
    public var body: some View {
        
        Circle()
            .frame(width: size, height: size)
            .foregroundColor(color)
            .opacity(isAnimated ? 1 : 0)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay))
            .onAppear {
                withAnimation {
                    isAnimated = true
                }
            }
    }
}
