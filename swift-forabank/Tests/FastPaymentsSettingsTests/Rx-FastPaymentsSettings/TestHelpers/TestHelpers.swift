//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import Foundation

func anyMessage() -> String {
    
    UUID().uuidString
}

func makeProduct(
    _ id: Product.ID = .init(generateRandom11DigitNumber()),
    type: Product.ProductType = .account,
    header: String = "Header",
    title: String = "title",
    number: String = "number",
    amountFormatted: String = "amountFormatted",
    balance: Decimal = 12_345.67,
    look: Product.Look = .init(
        background: .svg("background"),
        color: "green",
        icon: .svg("icon")
    )
) -> Product {
    
    .init(
        id: id,
        type: type,
        header: header,
        title: title,
        number: number,
        amountFormatted: amountFormatted,
        balance: balance,
        look: look
    )
}
