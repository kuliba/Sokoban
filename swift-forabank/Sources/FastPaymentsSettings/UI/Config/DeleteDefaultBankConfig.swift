//
//  DeleteDefaultBankConfig.swift
//  
//
//  Created by Дмитрий Савушкин on 29.09.2024.
//

import SwiftUI
import SharedConfigs

public struct DeleteDefaultBankConfig {
    
    let title: String
    let titleConfig: TextConfig
    let description: String
    let descriptionConfig: TextConfig
    let iconConfig: IconConfig
    let buttonConfig: ButtonConfig
    let backgroundView: Color
    
    public init(
        title: String,
        titleConfig: TextConfig,
        description: String,
        descriptionConfig: TextConfig,
        iconConfig: IconConfig,
        buttonConfig: ButtonConfig,
        backgroundView: Color
    ) {
        self.title = title
        self.titleConfig = titleConfig
        self.description = description
        self.descriptionConfig = descriptionConfig
        self.iconConfig = iconConfig
        self.buttonConfig = buttonConfig
        self.backgroundView = backgroundView
    }
}

public extension DeleteDefaultBankConfig {
    
    struct IconConfig {
        
        let icon: Image
        let foreground: Color
        
        public init(
            icon: Image,
            foreground: Color
        ) {
            self.icon = icon
            self.foreground = foreground
        }
    }
    
    struct ButtonConfig {
        
        let icon: Image
        let foreground: Color
        
        public init(
            icon: Image,
            foreground: Color
        ) {
            self.icon = icon
            self.foreground = foreground
        }
    }
}
