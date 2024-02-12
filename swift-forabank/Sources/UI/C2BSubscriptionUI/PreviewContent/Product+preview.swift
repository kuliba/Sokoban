//
//  Product+preview.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

extension Product {
    
    static let preview: Self = .init(
        id: .account(1234567890),
        title: "Счет списания",
        name: "Текущий счет",
        number: "3387",
        icon: .svg(""),
        balance: "654 367 ₽"
    )
    
    static let card: Self = .init(
        id: .card(10000198241),
        title: "Карта списания",
        name: "Текущий счет",
        number: "3387",
        icon: .svg(""),
        balance: "654 367 ₽"
    )
}
