//
//  SelectorConfig.swift
//
//
//  Created by Disman Dmitry on 05.03.2024.
//

import SwiftUI
import Tagged

public struct SelectorConfig {
    
    let optionConfig: OptionConfig
    let itemSpacing: CGFloat

    public init(
        optionConfig: OptionConfig,
        itemSpacing: CGFloat
    ) {
        self.optionConfig = optionConfig
        self.itemSpacing = itemSpacing
    }
}

public extension SelectorConfig {
    
    struct OptionConfig {
        
        let frameHeight: CGFloat
        let textFont: Font
        let textForeground: Color
        let textForegroundSelected: Color
        let shapeForeground: Color
        let shapeForegroundSelected: Color
        
        public init(
            frameHeight: CGFloat,
            textFont: Font,
            textForeground: Color,
            textForegroundSelected: Color,
            shapeForeground: Color,
            shapeForegroundSelected: Color
        ) {
            self.frameHeight = frameHeight
            self.textFont = textFont
            self.textForeground = textForeground
            self.textForegroundSelected = textForegroundSelected
            self.shapeForeground = shapeForeground
            self.shapeForegroundSelected = shapeForegroundSelected
        }
    }
}
