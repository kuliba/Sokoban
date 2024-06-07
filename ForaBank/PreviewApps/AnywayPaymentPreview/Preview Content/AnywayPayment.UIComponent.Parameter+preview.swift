//
//  AnywayPayment.UIComponent.Parameter+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain

extension AnywayElement.UIComponent.Parameter {
    
    static let preview: Self = .init(
        id: .init("abc"),
        type: .numberInput,
        title: "Enter some number",
        subtitle: nil,
        value: nil
    )
}
