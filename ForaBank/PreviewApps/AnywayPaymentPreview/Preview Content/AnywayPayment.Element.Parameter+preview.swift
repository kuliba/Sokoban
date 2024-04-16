//
//  AnywayPayment.Element.Parameter+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 15.04.2024.
//

import AnywayPaymentCore

extension AnywayPayment.Element.Parameter {
    
    static let emptyTextInput: Self = .init(
        field: .init(id: "emptyTextInput", value: nil),
        masking: .preview,
        validation: .preview,
        uiAttributes: .textInput
    )
    static let textInput: Self = .init(
        field: .preview,
        masking: .preview,
        validation: .preview,
        uiAttributes: .textInput
    )
    static let select: Self = .init(
        field: .preview,
        masking: .preview,
        validation: .preview,
        uiAttributes: .select
    )
}

private extension AnywayPayment.Element.Parameter.Field {
    
    static let preview: Self = .init(id: "123", value: "abc")
}

private extension AnywayPayment.Element.Parameter.Masking {
    
    static let preview: Self = .empty
    static let empty: Self = .init(inputMask: nil, mask: nil)
}

private extension AnywayPayment.Element.Parameter.Validation {
    
    static let preview: Self = .required
    static let required: Self = .init(isRequired: true, maxLength: nil, minLength: nil, regExp: "")
}

private extension AnywayPayment.Element.Parameter.UIAttributes {
    
    static let select: Self = preview(
        dataType: .pairs([
            .init(key: "0", value: "abc"),
            .init(key: "1", value: "ABC"),
            .init(key: "2", value: "cdef"),
        ]),
        type: .select,
        viewType: .input
    )
    static let textInput: Self = preview(
        dataType: .string,
        type: .input,
        viewType: .input
    )
    
    private static func preview(
        dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType,
        type: AnywayPayment.Element.Parameter.UIAttributes.FieldType,
        viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType
    ) -> Self {
        
        .init(
            dataType: dataType,
            group: nil,
            isPrint: true,
            phoneBook: false,
            isReadOnly: false,
            subGroup: nil,
            subTitle: nil,
            svgImage: nil,
            title: "title",
            type: type,
            viewType: viewType
        )
    }
}
