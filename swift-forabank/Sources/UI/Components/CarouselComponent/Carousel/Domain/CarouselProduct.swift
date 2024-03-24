//
//  CarouselProduct.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI
import Tagged

public struct CarouselProduct: CarouselProductProtocol, Identifiable {
    
    public var type: CarouselProductType
    public var cardType: CarouselCardType?
    
    public let id: ID
    let order: Int
    
    public init(id: ID, order: Int, type: ProductType, cardType: CardType?) {
        self.id = id
        self.order = order
        self.type = type
        self.cardType = cardType
    }
}

public extension CarouselProduct {
    
    enum CarouselProductType: Equatable {
        
        case card, account, deposit, loan
    }
    
#warning("Добавить недостающие поля в v6/getProductListByType")
    enum CarouselCardType {
        
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

public extension CarouselProduct {
    
    typealias IDParent = Tagged<_IDParent, Int>
    enum _IDParent {}
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
}

extension CarouselProduct.CarouselProductType {
    
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
