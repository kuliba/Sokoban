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
    
    static let rub = Currency(description: "RUB")
    static let usd = Currency(description: "USD")
    static let eur = Currency(description: "EUR")
    static let gbp = Currency(description: "GBP")
    static let chf = Currency(description: "CHF")
    static let chy = Currency(description: "CHY")
    
    var currencyTitle: String {
        
        switch self {
        case .rub: return "в рублях"
        case .usd: return "в долларах США"
        case .eur: return "в евро"
        case .gbp: return "в фунтах стерлингов"
        case .chf: return "в швейцарских франках"
        case .chy: return "в китайских юанях"
        default:
            return ""
        }
    }
    
    var order: Int {
        
        switch self {
        case .usd: return 1
        case .eur: return 2
        case .gbp: return 3
        case .chf: return 4
        case .chy: return 5
        default:
            return 0
        }
    }
}

//MARK: - Type

extension Currency {
    
    struct Rate {
        
        let code: String
        let name: String
        
    }
}
