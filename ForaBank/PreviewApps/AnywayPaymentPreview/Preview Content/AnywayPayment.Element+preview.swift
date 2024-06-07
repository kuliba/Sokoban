//
//  AnywayPayment.AnywayElement+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain

extension Array where Element == AnywayPayment.AnywayElement {
    
    static let preview: Self = [
        .field(.init(id: "1", title: "a", value: "bb")),
        .parameter(.select),
        .parameter(.emptyTextInput),
        .parameter(.textInput),
        .widget(.otp(nil))
    ]
}
