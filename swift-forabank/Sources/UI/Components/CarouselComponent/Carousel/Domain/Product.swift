//
//  Product.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI
import Tagged

public struct Product: Equatable, Identifiable, Hashable {
    
    public let id: ID
    let order: Int
    public let type: ProductType
    public let cardType: CardType?
    
    public init(id: ID, order: Int, type: ProductType, cardType: CardType?) {
        self.id = id
        self.order = order
        self.type = type
        self.cardType = cardType
    }
}

public extension Product {
    
    enum ProductType: Identifiable, Hashable {
        
        case card, account, deposit, loan
        
        public var id: _Case { _case }

        var _case: _Case {
            
            switch self {
            case .account: return .account
            case .card: return .card
            case .deposit: return .deposit
            case .loan: return .loan
            }
        }
        
        public enum _Case {
            
            case card, account, deposit, loan
        }
    }
    
#warning("Добавить недостающие поля в v6/getProductListByType")
    enum CardType: Int, Hashable, CaseIterable {
        
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
}

public extension Product {
    
    typealias IDParent = Tagged<_IDParent, Int>
    enum _IDParent {}
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
}

extension Product.ProductType {
    
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
