//
//  Product+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import Foundation

public extension Product {
    
    static let card: Self = _product(
        id: .init(generateRandom11DigitNumber()),
        type: .card,
        amountFormatted: "123.45"
    )
    
    static let account: Self = _product(
        id: .init(generateRandom11DigitNumber()),
        type: .account,
        amountFormatted: "98.76"
    )
    
    private static func _product(
        id: ID,
        type: ProductType,
        header: String? = nil,
        title: String = "title",
        amountFormatted: String,
        balance: Decimal = 12_345.67,
        look: Product.Look = .init(
            background: .svg("background"),
            color: "green",
            icon: .svg("icon")
        )
    ) -> Self {
        
        .init(
            id: id,
            type: type,
            header: header ?? type.rawValue,
            title: title,
            number: .init(String(id.rawValue).prefix(4)),
            amountFormatted: amountFormatted,
            balance: balance,
            look: look
        )
    }
}

private extension Product.ProductType {
    
    var rawValue: String {
        
        switch self {
        case .account: return "Account"
        case .card:    return "Card"
        }
    }
}
