//
//  TextFieldView.TextFieldConfig+preview.swift
//
//
//  Created by Igor Malyarov on 10.02.2024.
//

import SwiftUI
import TextFieldUI

public extension TextFieldView.TextFieldConfig {
    
    static func preview(
        fontSize: CGFloat = 19,
        fontWeight: UIFont.Weight = .regular,
        textColor: Color = .orange,
        tintColor: Color = .black,
        backgroundColor: Color = .clear,
        placeholderColor: Color = .gray
    ) -> Self {
        
        return .init(
            font: .systemFont(ofSize: fontSize, weight: fontWeight),
            textColor: textColor,
            tintColor: tintColor,
            backgroundColor: backgroundColor,
            placeholderColor: placeholderColor
        )
    }
}
