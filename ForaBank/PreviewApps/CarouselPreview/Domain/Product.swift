//
//  Product.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import SwiftUI
import CarouselComponent

struct Product: Identifiable {
    
    let id: Int
    let productType: ProductType
    let number: String
    let balance: String
    let productName: String
    let cardType: CardType?
    
    enum ProductType {
        
        case card
        case account
        case deposit
        case loan
        
        var type: CarouselProduct.ProductType {
            switch self {
            case .card:
                return .card
            case .account:
                return .account
            case .deposit:
                return .deposit
            case .loan:
                return .loan
            }
        }
    }
    
    enum CardType {
        
        case regular
        case main
        case additionalSelf
        case additionalSelfAccOwn
        case additionalOther
        
        var type: CarouselProduct.CardType {
            switch self {
            case .regular:
                return .regular
            case .main:
                return .main
            case .additionalSelf:
                return .additionalSelf
            case .additionalSelfAccOwn:
                return .additionalSelfAccOwn
            case .additionalOther:
                return .additionalOther
            }
        }
    }
}
