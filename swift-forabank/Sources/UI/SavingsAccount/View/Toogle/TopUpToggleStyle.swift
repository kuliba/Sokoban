//
//  TopUpToggleStyle.swift
//  
//
//  Created by Andryusina Nataly on 26.11.2024.
//

import SwiftUI
import UIPrimitives

struct TopUpToggleStyle: ToggleStyle {
    
    let config: ToggleConfig
    
    func makeBody(configuration: Configuration) -> some View {
        
        let offset: CGFloat = (config.size.width - (config.size.height - config.padding * 2) - config.padding * 2) / 2.0
        
        RoundedRectangle(cornerRadius: config.size.height, style: .circular)
            .stroke(style: .init(lineWidth: config.lineWidth))
            .fill(configuration.isOn ? config.colors.on : config.colors.off)
            .overlay(
                Circle()
                    .fill(configuration.isOn ? config.colors.on : config.colors.off)
                    .padding(config.padding)
                    .offset(x: configuration.isOn ? offset : -offset)
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    configuration.isOn.toggle()
                }
            }
            .frame(config.size)
    }
}

struct PreviewTopUpToggle: View {
    
    @State private(set) var isShowingProducts = false
    
    var body: some View {
        
        Toggle("", isOn: $isShowingProducts)
            .toggleStyle(TopUpToggleStyle(config: .preview))
    }
}

#Preview {
    
    PreviewTopUpToggle()
}
