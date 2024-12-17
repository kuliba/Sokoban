//
//  TextFieldView.TextFieldConfig+Extension.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.04.2023.
//

import TextFieldComponent

extension RegularTextFieldView.TextFieldConfig {
    
    static let black16: Self = .init(
        font: .textH4M16240(),
        textColor: .black,
        tintColor: .black,
        backgroundColor: .clear,
        placeholderColor: .gray
    )
}
