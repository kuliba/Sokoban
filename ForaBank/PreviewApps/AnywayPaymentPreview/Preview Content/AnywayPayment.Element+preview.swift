//
//  AnywayPayment.Element+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore

extension Array where Element == AnywayPayment.Element {
    
    static let preview: Self = [
        .field(.init(id: "1", title: "a", value: "bb")),
        .parameter(.textInput),
        .parameter(.select),
        .widget(.otp(nil))
    ]
}
