//
//  ProductSelect.Product+ext.swift
//
//
//  Created by Igor Malyarov on 22.12.2023.
//

import UIPrimitives

public extension Array where Element == ProductSelect.Product {
    
    static let allProducts: Self = [
        .accountPreview,
        .account2Preview,
        .cardPreview,
        .card2Preview,
        .card3Preview,
    ]
}

extension ProductSelect.Product {
    
    public static let accountPreview: Self = .init(
        id: 234567891,
        type: .account, 
        isAdditional: false,
        header: "Счет списания",
        title: "Текущий счет",
        footer: "7891",
        amountFormatted: "123 456 ₽",
        balance: 123_456,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    static let account2Preview: Self = .init(
        id: 2345678912,
        type: .account,
        isAdditional: false,
        header: "Счет списания",
        title: "Account 2",
        footer: "8912",
        amountFormatted: "678.09 ₽",
        balance: 678.09,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    public static let cardPreview: Self = .init(
        id: 123456789,
        type: .card,
        isAdditional: false,
        header: "Счет списания",
        title: "Card",
        footer: "6789",
        amountFormatted: "1 234.56 ₽",
        balance: 1_234.56,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    static let card2Preview: Self = .init(
        id: 1234567892,
        type: .card,
        isAdditional: true,
        header: "Счет списания",
        title: "Card 2",
        footer: "7892",
        amountFormatted: "12 345 ₽",
        balance: 12_345,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
    
    static let card3Preview: Self = .init(
        id: 1234567893,
        type: .card,
        isAdditional: false,
        header: "Счет списания",
        title: "Card 3",
        footer: "7893",
        amountFormatted: "123 456.78 ₽",
        balance: 123_456.78,
        look: .init(
            background: .svg(""),
            color: "orange",
            icon: .svg("")
        )
    )
}

