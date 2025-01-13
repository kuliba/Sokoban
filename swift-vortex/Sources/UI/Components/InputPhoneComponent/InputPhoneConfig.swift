//
//  InputPhoneConfig.swift
//
//
//  Created by Дмитрий Савушкин on 26.04.2024.
//

import Foundation
import SwiftUI
import SharedConfigs
import TextFieldComponent

public struct InputPhoneConfig {
    
    let icon: Image
    let iconForeground: Color
    
    let placeholder: String
    let placeholderConfig: TextConfig

    let title: String
    let titleConfig: TextConfig
    
    let buttonIcon: Image
    let buttonForeground: Color
    
    let textFieldConfig: TextFieldView.TextFieldConfig
    
    public init(
        icon: Image,
        iconForeground: Color,
        placeholder: String,
        placeholderConfig: TextConfig,
        title: String,
        titleConfig: TextConfig,
        buttonIcon: Image,
        buttonForeground: Color,
        textFieldConfig: TextFieldView.TextFieldConfig
    ) {
        self.icon = icon
        self.iconForeground = iconForeground
        self.placeholder = placeholder
        self.placeholderConfig = placeholderConfig
        self.title = title
        self.titleConfig = titleConfig
        self.buttonIcon = buttonIcon
        self.buttonForeground = buttonForeground
        self.textFieldConfig = textFieldConfig
    }
}
