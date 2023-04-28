//
//  MainProductsGroupSettings.swift
//  ForaBank
//
//  Created by Max Gribov on 19.05.2022.
//

import Foundation

struct MainProductsGroupSettings {
    
    /// Maximum amount of cards allowed to get free card
    let maxAllowedCardsForNewProduct: Int
    
    func isFreeCardAllowed(for products: ProductsData) -> Bool {
        
        guard let cardsCount = products[.card]?.count else {
            return true
        }
        
        return cardsCount <= maxAllowedCardsForNewProduct
    }
}

extension MainProductsGroupSettings {
    
    static let base: Self = .init(maxAllowedCardsForNewProduct: 1)
}
