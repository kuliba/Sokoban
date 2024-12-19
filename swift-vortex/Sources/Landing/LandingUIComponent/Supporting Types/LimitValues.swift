//
//  LimitValues.swift
//
//
//  Created by Andryusina Nataly on 20.06.2024.
//

import Foundation

public struct LimitValues: Equatable {
   
    let currency: String 
    let currentValue: Decimal
    let name: String
    let value: Decimal
    
    public init(
        currency: String,
        currentValue: Decimal,
        name: String,
        value: Decimal
    ) {
        self.currency = currency
        self.currentValue = currentValue
        self.name = name
        self.value = value
    }
}
