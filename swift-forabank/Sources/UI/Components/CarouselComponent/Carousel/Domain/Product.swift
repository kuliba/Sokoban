//
//  Product.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI
import Tagged

public struct Product: CarouselProduct, Equatable, Identifiable {
    
    public var type: ProductType
    public var cardType: CardType?
    
    public let id: ID
    
    public init(id: ID, type: ProductType, cardType: CardType?) {
        self.id = id
        self.type = type
        self.cardType = cardType
    }
}

public enum ProductType: Equatable {
    
    case card, account, deposit, loan
}

#warning("Добавить недостающие поля в v6/getProductListByType")
public enum CardType {
    
    case regular
    case main
    case additionalSelf
    case additionalSelfAccOwn
    case additionalOther
    
    public var isAdditional: Bool {
        self == .additionalSelf ||
        self == .additionalSelfAccOwn ||
        self == .additionalOther
    }
    
    public var isMainOrRegular: Bool {
        self == .main ||
        self == .regular
    }
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
