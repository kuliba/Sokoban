//
//  CurrencyData.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

struct Currency: CustomStringConvertible, Equatable  {
    
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
