//
//  CreateDraftCollateralLoanApplicationConfig+Amount.swift
//
//
//  Created by Valentin Ozerov on 27.01.2025.
//

import InputComponent
import SwiftUI
import TextFieldUI

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Amount {
        
        public let title: String
        public let inputComponentConfig: TextInputConfig

        public init(
            title: String,
            inputComponentConfig: TextInputConfig
        ) {
            self.title = title
            self.inputComponentConfig = inputComponentConfig
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Amount {
    
    static let preview = Self(
        title: "Сумма кредита",
        inputComponentConfig: .preview
    )
}

extension TextInputConfig {
    
    static let preview = Self(
        hint: .init(textFont: .footnote, textColor: .red),
        imageWidth: 24,
        keyboard: .number,
        placeholder: "Введите сумму кредита",
        textField: .preview,
        title: "Сумма кредита",
        titleConfig: .init(textFont: Font.system(size: 14), textColor: .title),
        toolbar: .preview,
        warning: .init(textFont: .footnote, textColor: .red)
    )
}

extension TextFieldView.TextFieldConfig {
    
    static let preview = Self(
        font: .systemFont(ofSize: 16),
        textColor: .primary,
        tintColor: .accentColor,
        backgroundColor: .clear,
        placeholderColor: .clear
    )
}

extension ToolbarConfig {
    
    static let preview = Self(
        closeImage: "closeImage",
        doneTitle: "Готово"
    )
}

private extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
}

