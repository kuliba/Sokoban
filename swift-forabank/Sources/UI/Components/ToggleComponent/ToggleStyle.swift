//
//  ToggleStyle.swift
//
//
//  Created by Valentin Ozerov on 09.12.2024.
//

import SwiftUI
import UIPrimitives

struct ToggleComponentStyle: ToggleStyle {
    
    let config: ToggleConfig
    
    func makeBody(configuration: Configuration) -> some View {
        
        let offset = (config.size.width - (config.size.height - config.padding * 2) - config.padding * 2) / 2.0
        
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
