//
//  Product.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI
import Tagged

public struct Product: CarouselProduct, Equatable, Identifiable {
    
    public let id: ID
    public var type: ProductType
    public var isAdditional: Bool?
    
    public init(id: ID, type: ProductType, isAdditional: Bool? = nil) {
        self.id = id
        self.type = type
        self.isAdditional = isAdditional
    }
}

public enum ProductType: Equatable {
    
    case card, account, deposit, loan
}

public extension Product {
    
    typealias IDParent = Tagged<_IDParent, Int>
    enum _IDParent {}
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
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
