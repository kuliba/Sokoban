//
//  Product.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI
import Tagged

public struct Product: Equatable, Identifiable {
    
    public typealias IDParent = Tagged<_IDParent, Int>
    public enum _IDParent {}
    
    public let id: ID
    let order: Int
    
    public init(
        id: ID,
        order: Int
    ) {
        self.id = id
        self.order = order
    }
}

public extension Product {
    
    struct ID: Hashable {
        
        public let value: Tagged<Self, Int>
        public let type: ProductType
        public let cardType: CardType?
        
        public enum ProductType: Hashable {
            
            case card, account, deposit, loan
        }
        
        #warning("Добавить недостающие поля в v6/getProductListByType")
        public enum CardType: Int, Hashable, CaseIterable {
            
            case regular
            case main
            case additionalSelf
            case additionalSelfAccOwn
            case additionalOther
            case sticker
            
            public var isAdditional: Bool {
                self == .additionalSelf ||
                self == .additionalSelfAccOwn ||
                self == .additionalOther
            }
            
            public var isMainOrRegular: Bool {
                self == .main ||
                self == .regular
            }
            
            public var isSticker: Bool {
                self == .sticker
            }
        }
        
        public init(
            value: Tagged<Self, Int>,
            type: ProductType,
            cardType: CardType? = nil
        ) {
            self.value = value
            self.type = type
            self.cardType = cardType
        }
    }
}

extension Product.ID.ProductType {
    
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
