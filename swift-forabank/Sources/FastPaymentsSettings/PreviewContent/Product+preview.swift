//
//  Product+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import Foundation

public extension Product {
    
    static let account: Self = _product(
        id: .account(.init(generateRandom11DigitNumber())),
        amountFormatted: "98.76"
    )
    
    static let card: Self = _product(
        id: .card(
            .init(generateRandom11DigitNumber()),
            accountID: .init(generateRandom11DigitNumber())
        ),
        amountFormatted: "123.45"
    )
    
    private static func _product(
        id: ID,
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
            header: header ?? id.typeString,
            title: title,
            number: id.numberString,
            amountFormatted: amountFormatted,
            balance: balance,
            look: look
        )
    }
}

private extension ProductID
where AccountID: RawRepresentable<Int>,
      CardID: RawRepresentable<Int> {
    
    var typeString: String {
        
        switch self {
        case .account: return "Account"
        case .card: return "Card"
        }
    }
    
    var numberString: String { .init(String(rawID).prefix(4)) }
    
    private var rawID: Int {
        
        switch self {
        case let .account(accountID): return accountID.rawValue
        case let .card(cardID, _): return cardID.rawValue
        }
    }
}
