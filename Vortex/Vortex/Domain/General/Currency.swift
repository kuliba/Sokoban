//
//  CurrencyData.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

struct Currency: CustomStringConvertible, Equatable, Hashable  {
    
    let description: String
}

extension Currency: Codable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        description = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension Currency {
    //only in mocks
    static let rub = Currency(description: "RUB")
    static let usd = Currency(description: "USD")
    static let eur = Currency(description: "EUR")
    static let gbp = Currency(description: "GBP")
    static let chf = Currency(description: "CHF")
    static let cny = Currency(description: "CNY")
    static let amd = Currency(description: "AMD")
    
}
