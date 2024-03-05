//
//  ProductType.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

public enum ProductType: String, Equatable, CaseIterable, Hashable {
    
    case card = "CARD"
    case account = "ACCOUNT"
    case deposit = "DEPOSIT"
    case loan = "LOAN"
}

extension ProductType {
    
    var pluralName: String {
        
        switch self {
        case .card: return "Карты"
        case .account: return "Счета"
        case .deposit: return "Вклады"
        case .loan: return "Кредиты"
        }
    }
    
    var order: Int {
        
        switch self {
        case .card: return 0
        case .account: return 1
        case .deposit: return 2
        case .loan: return 3
        }
    }
}
