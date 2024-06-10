//
//  AnywayElement.Parameter+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 15.04.2024.
//

import AnywayPaymentDomain

extension AnywayElement.Parameter {
    
    static let emptyTextInput: Self = .init(
        field: .init(id: "emptyTextInput", value: nil), image: nil,
        masking: .preview,
        validation: .preview,
        uiAttributes: .textInput
    )
    static let textInput: Self = .init(
        field: .init(id: "textInput", value: "abc"), image: nil,
        masking: .preview,
        validation: .preview,
        uiAttributes: .textInput
    )
    static let select: Self = .init(
        field: .init(id: "select", value: "DFG"), image: nil,
        masking: .preview,
        validation: .preview,
        uiAttributes: .select
    )
}

private extension AnywayElement.Parameter.Masking {
    
    static let preview: Self = .empty
    static let empty: Self = .init(inputMask: nil, mask: nil)
}

private extension AnywayElement.Parameter.Validation {
    
    static let preview: Self = .required
    static let required: Self = .init(isRequired: true, maxLength: nil, minLength: nil, regExp: "")
}

private extension AnywayElement.Parameter.UIAttributes {
    
    static let select: Self = preview(
        dataType: .pairs(
            .init(key: "0", value: "abc"), [
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
        dataType: AnywayElement.Parameter.UIAttributes.DataType,
        type: AnywayElement.Parameter.UIAttributes.FieldType,
        viewType: AnywayElement.Parameter.UIAttributes.ViewType
    ) -> Self {
        
        return .init(
            dataType: dataType,
            group: nil,
            isPrint: true,
            phoneBook: false,
            isReadOnly: false,
            subGroup: nil,
            subTitle: nil,
            title: "title",
            type: type,
            viewType: viewType
        )
    }
}
