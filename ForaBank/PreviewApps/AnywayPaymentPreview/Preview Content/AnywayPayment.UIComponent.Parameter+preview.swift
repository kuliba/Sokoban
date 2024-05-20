//
//  AnywayPayment.UIComponent.Parameter+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain

extension AnywayPayment.Element.UIComponent.Parameter {
    
    static let preview: Self = .init(
        id: ".init(abc123)",
        type: .textInput,
        value: "ABCDE"
    )
}
