//
//  CreateDraftCollateralLoanApplicationConfig+InputComponent.swift
//
//
//  Created by Valentin Ozerov on 24.01.2025.
//

import InputComponent
import SwiftUI
import TextFieldUI

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
        font: .boldSystemFont(ofSize: 24),
        textColor: .title,
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

