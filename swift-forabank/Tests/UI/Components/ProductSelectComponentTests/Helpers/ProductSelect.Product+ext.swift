//
//  Helpers.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import ProductSelectComponent

extension ProductSelect.Product {
    
    static let test: Self = .init(
        id: 12345678,
        type: .card, 
        isAdditional: false,
        header: "Счет списания",
        title: "Title",
        footer: "5678",
        amountFormatted: "12.67 $",
        balance: 12.67,
        look: .test(color: "red")
    )
    
    static let test2: Self = .init(
        id: 23456789,
        type: .card, 
        isAdditional: false,
        header: "Счет списания",
        title: "Title",
        footer: "6789",
        amountFormatted: "4.21 $",
        balance: 4.21,
        look: .test(color: "blue")
    )
    
    static let missing: Self = .init(
        id: 1111111,
        type: .card, 
        isAdditional: false,
        header: "Счет списания",
        title: "Title",
        footer: "1111",
        amountFormatted: "12.67 $",
        balance: 12.67,
        look: .test(color: "red")
    )
}
