//
//  SelectConfig.swift
//
//
//  Created by Дмитрий Савушкин on 24.04.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public struct SelectConfig {
    
    let title: String
    let titleConfig: TextConfig
    
    let placeholder: String
    let placeholderConfig: TextConfig
    
    let backgroundIcon: Color
    let foregroundIcon: Color
    let icon: Image
    
    let isSearchable: Bool
    let optionConfig: OptionConfig
    
    public init(
        title: String,
        titleConfig: TextConfig,
        placeholder: String,
        placeholderConfig: TextConfig,
        backgroundIcon: Color,
        foregroundIcon: Color,
        icon: Image,
        isSearchable: Bool,
        optionConfig: OptionConfig
    ) {
        self.title = title
        self.titleConfig = titleConfig
        self.placeholder = placeholder
        self.placeholderConfig = placeholderConfig
        self.backgroundIcon = backgroundIcon
        self.foregroundIcon = foregroundIcon
        self.icon = icon
        self.isSearchable = isSearchable
        self.optionConfig = optionConfig
    }
}

public extension SelectConfig {
    
    struct OptionConfig {
        
        let icon: Image
        let foreground: Color
        let background: Color
        
        let selectIcon: Image
        let selectForeground: Color
        let selectBackground: Color
        
        let mainBackground: Color
        
        let size: Double
        
        public init(
            icon: Image,
            foreground: Color,
            background: Color,
            selectIcon: Image,
            selectForeground: Color,
            selectBackground: Color,
            mainBackground: Color,
            size: Double
        ) {
            self.icon = icon
            self.foreground = foreground
            self.background = background
            self.selectIcon = selectIcon
            self.selectForeground = selectForeground
            self.selectBackground = selectBackground
            self.mainBackground = mainBackground
            self.size = size
        }
    }
}
