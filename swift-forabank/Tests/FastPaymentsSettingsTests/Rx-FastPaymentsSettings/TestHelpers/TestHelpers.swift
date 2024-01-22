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
    _ rawValue: Int = generateRandom11DigitNumber(),
    productType: Product.ProductType = .account
) -> Product {
    
    .init(id: .init(rawValue), productType: productType)
}
