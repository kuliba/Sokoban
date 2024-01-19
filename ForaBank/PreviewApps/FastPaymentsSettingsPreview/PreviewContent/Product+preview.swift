//
//  Product+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings

extension Product {
    
    static let card: Self = .init(
        id: .init(generateRandom11DigitNumber()),
        productType: .card
    )
    
    static let account: Self = .init(
        id: .init(generateRandom11DigitNumber()),
        productType: .account
    )
}
