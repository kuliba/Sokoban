//
//  CustomDecimal.swift
//
//
//  Created by Igor Malyarov on 06.09.2024.
//

import Foundation

/// A custom struct that decodes a decimal value from a string using a specified format.
struct CustomDecimal: Decodable {
    
    let value: Decimal
    
    /// Initialises a `CustomDecimal` by decoding a string and converting it into a `Decimal` using a `NumberFormatter`.
    /// 
    /// - Parameter decoder: The decoder used to extract the value from JSON.
    /// - Throws: A `DecodingError` if the string cannot be converted into a valid `Decimal`.
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        let decimalString = try container.decode(String.self)
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        
        if let number = formatter.number(from: decimalString) {
            self.value = number.decimalValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid decimal value: \(decimalString)")
        }
    }
}
