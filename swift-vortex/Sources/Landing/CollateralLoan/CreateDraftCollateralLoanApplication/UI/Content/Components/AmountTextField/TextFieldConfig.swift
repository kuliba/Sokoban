//
//  TextFieldConfig.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 21.03.2025.
//

import SwiftUI

extension AmountFieldView {
    
    public struct TextFieldConfig: Equatable {
        
        // TODO: wrapper Font -> UIFont required
        let font: UIFont
        let textColor: Color
        let tintColor: Color
        let backgroundColor: Color
        let placeholderColor: Color
        
        public init(
            font: UIFont,
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
}
