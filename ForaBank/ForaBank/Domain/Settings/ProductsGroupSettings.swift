//
//  ProductsGroupSettings.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.03.2023.
//

import Foundation

struct ProductsGroupSettings {
    
    /// Minimum amount of products that should be visible any time
    let minVisibleProductsAmount: Int
}

extension ProductsGroupSettings {
    
    static let base: Self = .init(minVisibleProductsAmount: 3)
}
