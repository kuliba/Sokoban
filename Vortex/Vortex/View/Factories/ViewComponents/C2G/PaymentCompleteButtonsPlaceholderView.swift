//
//  PaymentCompleteButtonsPlaceholderView.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI

struct PaymentCompleteButtonsPlaceholderView: View {
    
    let config: PaymentCompleteButtonsPlaceholderViewConfig
    
    var body: some View {
        
        VStack(spacing: config.outerSpacing) {
            
            config.color
                .clipShape(Circle())
                .foregroundColor(config.color)
                .frame(config.circleSize)
            
            VStack(spacing: config.innerSpacing) {
                
                rect()
                    .frame(width: config.topRectWidth)
                
                rect()
                    .frame(width: config.bottomRectWidth)
            }
        }
    }
    
    private func rect() -> some View {
        
        config.color
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
            .frame(height: config.rectHeight)
    }
}

struct PaymentCompleteButtonsPlaceholderViewConfig: Equatable {
    
    let color: Color
    let circle: CGFloat
    let outerSpacing: CGFloat
    let innerSpacing: CGFloat
    let cornerRadius: CGFloat
    let rectHeight: CGFloat
    let topRectWidth: CGFloat
    let bottomRectWidth: CGFloat
    
    var circleSize: CGSize { .init(width: circle, height: circle)}
}

#Preview {
    
    PaymentCompleteButtonsPlaceholderView(config: .iVortex)
}
