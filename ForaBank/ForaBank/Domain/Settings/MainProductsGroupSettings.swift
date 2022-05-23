//
//  MainProductsGroupSettings.swift
//  ForaBank
//
//  Created by Max Gribov on 19.05.2022.
//

import Foundation

struct MainProductsGroupSettings {
    
    /// Minimum amount of products that should be visible any time
    let minVisibleProductsAmount: Int
    
    
    /// Maximum amount of card that requered new product button
    let maxCardsAmountRequeredNewProduct: Int
}

extension MainProductsGroupSettings {
    
    static let base = MainProductsGroupSettings(minVisibleProductsAmount: 2,
                                                maxCardsAmountRequeredNewProduct: 1)
}
