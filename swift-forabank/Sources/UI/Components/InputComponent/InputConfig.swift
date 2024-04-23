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
    let imageSize: ImageSize
    
    internal init(
        titleConfig: TextConfig,
        textFieldFont: TextConfig,
        placeholder: String,
        hintConfig: TextConfig,
        backgroundColor: Color,
        imageSize: InputConfig.ImageSize
    ) {
        self.titleConfig = titleConfig
        self.textFieldFont = textFieldFont
        self.placeholder = placeholder
        self.hintConfig = hintConfig
        self.backgroundColor = backgroundColor
        self.imageSize = imageSize
    }
    
    enum ImageSize: CGFloat {
        
        case small = 24
        case large = 32
    }
}
