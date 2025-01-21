//
//  Item.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 20.01.2025.
//

import SwiftUI

protocol ProductTypeable {
    
    var type: Product.ProductType { get }
}

extension Product.ProductType {
    
    var rawValue: String {
        
        switch self {
        case .card:
            return "card"
        case .account:
            return "account"
        case .deposit:
            return "deposit"
        case .loan:
            return "loan"
        }
    }
}

extension Product.ProductType: Identifiable {
    
    var id: String { rawValue }
}

struct Promo: Equatable, Identifiable, ProductTypeable {
    
    typealias ProductType = Product.ProductType
    
    let id: Int
    let color: Color
    let title: String
    let isHidden: Bool
    var type: ProductType
}

struct Item: Equatable, Identifiable, ProductTypeable {
    
    typealias ProductType = Product.ProductType
    
    let id: Int
    let color: Color
    let title: String
    var type: ProductType
}

struct NewProduct: Equatable, Identifiable, ProductTypeable {
    
    typealias ProductType = Product.ProductType
    
    let id: Int
    let color: Color
    let title: String
    var type: ProductType
}
