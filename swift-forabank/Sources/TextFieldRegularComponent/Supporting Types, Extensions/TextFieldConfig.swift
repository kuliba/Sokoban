//
//  TextFieldConfig.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import SwiftUI

extension TextFieldRegularView {
    
    public struct TextFieldConfig {
        
        //TODO: wrapper Font -> UIFont required
        let font: UIFont
        let textColor: Color
        let tintColor: Color
        let backgroundColor: Color
        

        public init(
            font: UIFont = .systemFont(ofSize: 19, weight: .regular),
            textColor: Color,
            tintColor: Color = .black,
            backgroundColor: Color = .clear
        ) {
            self.font = font
            self.textColor = textColor
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor
        }
    }
}
