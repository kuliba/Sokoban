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
    static let cny = Currency(description: "CNY")
    static let amd = Currency(description: "AMD")
    
    var currencyTitle: String {
        
        switch self {
        case .rub: return "в рублях"
        case .usd: return "в долларах США"
        case .eur: return "в евро"
        case .gbp: return "в фунтах стерлингов"
        case .chf: return "в швейцарских франках"
        case .cny: return "в китайских юанях"
        case .amd: return "в армянских драмах"
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
        case .cny: return 5
        case .amd: return 6
        default:
            return 0
        }
    }
    
    var currencySymbol: String {

        switch self {

        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .chf: return "₣"
        case .cny: return "¥"
        case .amd: return "֏"
        default:
            return ""
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
