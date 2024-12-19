//
//  TextFieldConfig.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import SwiftUI

extension TextFieldView {
    
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
