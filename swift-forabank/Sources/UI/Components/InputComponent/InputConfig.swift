//
//  InputConfig.swift
//
//
//  Created by Дмитрий Савушкин on 22.04.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public struct InputConfig {
    
    let titleConfig: TextConfig
    let textFieldFont: TextConfig
    let placeholder: String
    let hintConfig: TextConfig
    public let backgroundColor: Color
    let imageSize: CGFloat
    let keyboardType: KeyboardType
    let limit: Int
    let regExp: String
    
    public init(
        titleConfig: TextConfig,
        textFieldFont: TextConfig,
        placeholder: String,
        hintConfig: TextConfig,
        backgroundColor: Color,
        imageSize: CGFloat,
        keyboardType: KeyboardType,
        limit: Int,
        regExp: String
    ) {
        self.titleConfig = titleConfig
        self.textFieldFont = textFieldFont
        self.placeholder = placeholder
        self.hintConfig = hintConfig
        self.backgroundColor = backgroundColor
        self.imageSize = imageSize
        self.keyboardType = keyboardType
        self.limit = limit
        self.regExp = regExp
    }
    
    public enum KeyboardType: Equatable {
        
        case `default`
        case number
        case decimal
    }
}
