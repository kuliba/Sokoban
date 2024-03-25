//
//  Product.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI
import Tagged

public enum ProductType: Equatable {
    
    case card, account, deposit, loan
}

extension ProductType {
    
    var pluralName: String {
        
        switch self {
        case .card:
            return "Карты"
        case .account:
            return "Счета"
        case .deposit:
            return "Вклады"
        case .loan:
            return "Кредиты"
        }
    }
    
    var order: Int {
        
        switch self {
        case .card:
            return 0
        case .account:
            return 1
        case .deposit:
            return 2
        case .loan:
            return 3
        }
    }
}
