//
//  View+animated.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.01.2025.
//

import SwiftUI

/// A reusable view modifier to add entry animations with a customizable transition.
extension View {
    
    /// Applies a default or custom entry animation to the view, including a customizable transition.
    ///
    /// - Parameters:
    ///   - animation: The animation to apply. Defaults to `.easeInOut`.
    ///   - initialScale: The initial scale factor. Defaults to `0.6`.
    ///   - initialOpacity: The initial opacity. Defaults to `0`.
    ///   - transition: The transition to apply when the view appears. Defaults to `.move(edge: .leading)`.
    /// - Returns: A view that animates on appearance with the specified transition.
    func animated(
        animation: Animation? = .easeInOut,
        initialScale: CGFloat = 0.6,
        scaleEffectAnchor: UnitPoint = .leading,
        initialOpacity: Double = 0,
        transition: AnyTransition = .move(edge: .leading)
    ) -> some View {
        
        AnimatedWithTransition(
            content: self,
            animation: animation,
            initialScale: initialScale,
            scaleEffectAnchor: scaleEffectAnchor,
            initialOpacity: initialOpacity,
            transition: transition
        )
    }
}

/// A wrapper view that adds entry animations with a customizable transition.
struct AnimatedWithTransition<Content: View>: View {
    
    @State private var isVisible = false
    
    let content: Content
    let animation: Animation?
    let initialScale: CGFloat
    let scaleEffectAnchor: UnitPoint
    let initialOpacity: Double
    let transition: AnyTransition
    
    var body: some View {
        
        content
            .scaleEffect(isVisible ? 1 : initialScale, anchor: scaleEffectAnchor)
            .opacity(isVisible ? 1 : initialOpacity)
            .transition(transition)
            .animation(animation, value: isVisible)
            .onFirstAppear { isVisible = true }
    }
}
