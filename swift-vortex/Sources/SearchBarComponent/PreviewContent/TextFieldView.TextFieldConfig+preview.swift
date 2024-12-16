//
//  TextFieldView.TextFieldConfig+preview.swift
//
//
//  Created by Igor Malyarov on 10.02.2024.
//

import TextFieldUI

public extension TextFieldView.TextFieldConfig {
    
    static let preview: Self = .init(
        font: .systemFont(ofSize: 19, weight: .regular),
        textColor: .orange,
        tintColor: .black,
        backgroundColor: .clear,
        placeholderColor: .gray
    )
}
