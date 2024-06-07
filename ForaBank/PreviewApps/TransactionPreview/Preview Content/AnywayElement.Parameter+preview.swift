//
//  AnywayElement.Parameter+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import Foundation

extension AnywayElement.Parameter {
    
    static let stringInput: Self = .init(
        field: .init(id: .init(UUID().uuidString), value: nil),
        masking: .none,
        validation: .init(
            isRequired: true,
            maxLength: nil,
            minLength: nil,
            regExp: ""
        ),
        uiAttributes: .init(
            dataType: .string,
            group: nil,
            isPrint: true,
            phoneBook: false,
            isReadOnly: false,
            subGroup: nil,
            subTitle: nil,
            svgImage: nil,
            title: "string input",
            type: .input,
            viewType: .input
        )
    )
}

extension AnywayElement.Parameter.Masking {
    
    static let none: Self = .init(inputMask: nil, mask: nil)
}
