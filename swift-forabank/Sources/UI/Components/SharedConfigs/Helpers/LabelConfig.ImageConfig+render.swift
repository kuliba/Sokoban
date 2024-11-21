//
//  LabelConfig.ImageConfig+render.swift
//
//
//  Created by Igor Malyarov on 13.11.2024.
//

import SwiftUI

public extension LabelConfig.ImageConfig {
    
    @ViewBuilder
    func render() -> some View {
        
        image
            .resizable()
            .frame(size)
            .frame(backgroundSize)
            .background(backgroundColor)
            .foregroundColor(color)
    }
}

private extension View {
    
    func frame(_ size: CGSize) -> some View {
        
        frame(width: size.width, height: size.height)
    }
}
