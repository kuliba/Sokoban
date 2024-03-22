//
//  ProductData.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import SwiftUI

struct ProductData: Identifiable {
    
    let id: Int
    let productType: ProductType
    let number: String
    let balance: String
    let productName: String
    
    enum ProductType {
        
        case card
        case account
        case deposit
        case loan
    }
}
