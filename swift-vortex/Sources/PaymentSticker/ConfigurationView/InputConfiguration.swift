//
//  InputConfiguration.swift
//
//
//  Created by Дмитрий Савушкин on 13.12.2023.
//

import Foundation
import SwiftUI

public struct InputConfiguration {

    let titleFont: Font
    let titleColor: Color
    
    let iconColor: Color
    let iconName: String
    
    let warningFont: Font
    let warningColor: Color
    
    let textFieldFont: Font
    let textFieldColor: Color
    
    let textFieldTintColor: Color
    let textFieldBackgroundColor: Color
    let textFieldPlaceholderColor: Color
    
    public init(
        titleFont: Font,
        titleColor: Color,
        iconColor: Color,
        iconName: String,
        warningFont: Font,
        warningColor: Color,
        textFieldFont: Font,
        textFieldColor: Color,
        textFieldTintColor: Color,
        textFieldBackgroundColor: Color,
        textFieldPlaceholderColor: Color
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.iconName = iconName
        self.warningFont = warningFont
        self.warningColor = warningColor
        self.textFieldFont = textFieldFont
        self.textFieldColor = textFieldColor
        self.textFieldTintColor = textFieldTintColor
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textFieldPlaceholderColor = textFieldPlaceholderColor
    }
}
