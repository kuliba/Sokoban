//
//  TextFieldView+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.05.2023.
//

import Foundation
import TextFieldComponent
import SwiftUI

extension TextFieldComponent.TextFieldView {
    
    // MARK: Support Existing API
    
    @available(*, deprecated, message: "Use `init(viewModel:textFieldConfig:)`")
    init(
        viewModel: RegularFieldViewModel,
        font: UIFont = .systemFont(ofSize: 19, weight: .regular),
        backgroundColor: Color = .clear,
        tintColor: Color = .black,
        textColor: Color
    ) {

        self.init(
            viewModel: viewModel,
            textFieldConfig: .init(
                font: font,
                textColor: textColor,
                tintColor: tintColor,
                backgroundColor: backgroundColor,
                placeholderColor: .gray
            )
        )
    }
}

extension TextFieldComponent.TextFieldView.TextFieldConfig {
    
    static func makeDefault(
        font: UIFont = .systemFont(ofSize: 19, weight: .regular),
        textColor: Color = .black,
        tintColor: Color = .black,
        backgroundColor: Color = .clear,
        placeholderColor: Color = .gray
    ) -> Self {
        
        .init(font: font, textColor: textColor, tintColor: tintColor, backgroundColor: backgroundColor, placeholderColor: placeholderColor)
    }
}
