//
//  Preview.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 21.01.2025.
//

import Foundation

extension CarouselState {
    
    static let preview: Self = .init(newProducts: .preview, promo: .preview, products: .preview)
}

extension CarouselWithPromoView {
    
    static func event(_ event: CarouselEvent) {
        
        switch event {
        case let .product(event):
            switch event {
            case let .tap(productID):
                print("Product tap \(productID)")
            }
            
        case let .promo(event):
            switch event {
            case let .hidden(productID):
                print("Promo hidden \(productID)")
                
            case let .tap(productID):
                print("Promo tap \(productID)")
                
            }
        case let .newProduct(event):
            switch event {
            case let .tap(productID):
                print("New product tap \(productID)")
            }
        }
    }
}

extension Array where Element == Promo {
    
    static var preview: Self  = [
        .init(id: 10, color: .red, title: "Promo 10", isHidden: false, type: .account),
        .init(id: 13, color: .blue, title: "Promo 13", isHidden: false, type: .deposit),
        .init(id: 11, color: .green, title: "Promo 11", isHidden: false, type: .card),
        .init(id: 12, color: .orange, title: "Promo 12", isHidden: false, type: .loan)
    ]
}

extension Array where Element == Item {
    
    static var preview: Self = [
        .init(id: 0, color: .red, title: "Item 0  \(Product.ProductType.account.rawValue)", type: .account),
        .init(id: 1, color: .green, title: "Item 1  \(Product.ProductType.card.rawValue)", type: .card),
        .init(id: 2, color: .orange, title: "Item 2  \(Product.ProductType.loan.rawValue)", type: .loan),
        .init(id: 3, color: .blue, title: "Item 3  \(Product.ProductType.deposit.rawValue)", type: .deposit)
    ]
}

extension Array where Element == NewProduct {
    
    static var preview: Self = [
        .init(id: 111, color: .mint, title: "add new product", type: .loan)
    ]
}

extension Array where Element == Product.ProductType {
    
    static var allTypes: Self  = [
        .card,
        .account,
        .deposit,
        .loan
    ]
}
