//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

public struct AnimatedGradientView: View {
    
    var duration: TimeInterval
    @State private var isAnimated: Bool = false
    
    public init(duration: TimeInterval = 1.0) {
        self.duration = duration
    }
    
    public var body: some View {
        
        GeometryReader { proxy in
            
            LinearGradient(colors: [.white.opacity(0), .white.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                .offset(.init(width: isAnimated ? proxy.frame(in: .local).width * 2 : -proxy.frame(in: .local).width, height: 0))
                .animation(.easeInOut(duration: duration).repeatForever(autoreverses: false))
                .onAppear {
                    withAnimation {
                        isAnimated = true
                    }
                }
        }
    }
}
