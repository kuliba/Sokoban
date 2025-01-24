//
//  Logic.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 21.01.2025.
//

import Foundation

enum CarouselEvent {
    
    case newProduct(NewProductEvent)
    case promo(PromoEvent)
    case product(ProductEvent)
}

enum PromoEvent {
    
    case hidden(Int)
    case tap(Int)
}

enum ProductEvent {
    
    case tap(Int)
}

enum NewProductEvent {
    
    case tap(Int)
}

struct CarouselState {
    
    let newProducts: [NewProduct]
    let promo: [Promo]
    let products: [Item]
}
