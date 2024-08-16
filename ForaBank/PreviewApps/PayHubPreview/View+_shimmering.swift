//
//  View+_shimmering.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func _shimmering(
        isActive: Bool = true,
        animation: Animation = .shimmerDefault,
        gradient: Gradient = .shimmerDefault,
        width: CGFloat = 0.7
    ) -> some View {
        
        if isActive {
            self.modifier(
                Shimmering(
                    animation: animation,
                    gradient: gradient,
                    width: width
                )
            )
        } else {
            self
        }
    }
}

extension Animation {
    
    static let shimmerDefault: Self = .linear(duration: 0.9)
        .delay(0.25)
        .repeatForever(autoreverses: false)
}

extension Gradient {
    
    static let shimmerDefault: Self = .init(colors: [
        .green.opacity(0.2),
        .green,
        .green.opacity(0.2)
    ])
}

private struct Shimmering: ViewModifier {
    
    let animation: Animation
    let gradient: Gradient
    let width: CGFloat
    
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        
        content.mask(mask)
            .animation(animation, value: isAnimating)
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    
                    isAnimating = true
                }
            }
    }
    
    // TODO: add angle
    private var min: CGFloat { -width }
    private var max: CGFloat { 1 + width }
    
    var startPoint: UnitPoint {
        
        return .init(
            x: isAnimating ? max : 0,
            y: isAnimating ? max : 0
        )
    }
    
    var endPoint: UnitPoint {
        
        return .init(
            x: isAnimating ? 1 : min,
            y: isAnimating ? 1 : min
        )
    }
    
    private var mask: some View {
        
        LinearGradient(
            gradient: gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

struct Shimmering_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            Group {
                
                Text("Some text")
                Text("Some longer longer longer text")
                
                Text("Some text")
                    .redacted(reason: .placeholder)
                Text("Some longer longer longer text")
                    .redacted(reason: .placeholder)
                
                Color.red
                    .frame(height: 100)
                
                Color.red
                    .frame(height: 300)

                HStack {
                 
                    Circle()
                        .foregroundColor(.blue)
                        .frame(width: 100, height: 100)
                    
                    Rectangle()
                        .foregroundColor(.green)
                        .frame(height: 100)
                }
            }
            .font(.headline)
            ._shimmering()
        }
    }
}
