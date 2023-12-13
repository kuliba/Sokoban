//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 13.12.2023.
//

import Foundation
import SwiftUI
import TextFieldComponent

public struct SelectViewConfiguration {
    
    let selectOptionConfig: SelectedOptionConfig
    let optionsListConfig: OptionsListConfig
    let optionConfig: OptionConfig
    let textFieldConfig: TextFieldView.TextFieldConfig
    
    public init(
        selectOptionConfig: SelectedOptionConfig,
        optionsListConfig: OptionsListConfig,
        optionConfig: OptionConfig,
        textFieldConfig: TextFieldView.TextFieldConfig
    ) {
        self.selectOptionConfig = selectOptionConfig
        self.optionsListConfig = optionsListConfig
        self.optionConfig = optionConfig
        self.textFieldConfig = textFieldConfig
    }
    
    public struct TextFieldConfig {
    
        let font: Font
        let textColor: Color
        let tintColor: Color
        let backgroundColor: Color
        let placeholderColor: Color
        
        public init(
            font: Font,
            textColor: Color,
            tintColor: Color,
            backgroundColor: Color,
            placeholderColor: Color
        ) {
            self.font = font
            self.textColor = textColor
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor
            self.placeholderColor = placeholderColor
        }
    }
    
    public struct SelectedOptionConfig {
        
        let titleFont: Font
        let titleForeground: Color
        let placeholderForeground: Color
        let placeholderFont: Font
        
        public init(
            titleFont: Font,
            titleForeground: Color,
            placeholderForeground: Color,
            placeholderFont: Font
        ) {
            self.titleFont = titleFont
            self.titleForeground = titleForeground
            self.placeholderForeground = placeholderForeground
            self.placeholderFont = placeholderFont
        }
    }
    
    public struct OptionsListConfig {
        
        let titleFont: Font
        let titleForeground: Color
        
        public init(
            titleFont: Font,
            titleForeground: Color
        ) {
            self.titleFont = titleFont
            self.titleForeground = titleForeground
        }
    }
    
    public struct OptionConfig {
        
        let nameFont: Font
        let nameForeground: Color
        
        public init(
            nameFont: Font,
            nameForeground: Color
        ) {
            self.nameFont = nameFont
            self.nameForeground = nameForeground
        }
    }
}
