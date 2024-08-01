//
//  Model+currencyOf.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.05.2024.
//

import ProductSelectComponent

extension Model {
    
    func currencyOf(
        product: ProductSelect.Product
    ) -> String? {
        
        let first = allProducts.first { $0.matches(product) }
        
        return first?.currency
    }
}

private extension ProductData {
    
    func matches(
        _ product: ProductSelect.Product
    ) -> Bool {
        
        id == product.id.rawValue && productType.matches(product)
    }
}

private extension ProductType {
    
    func matches(
        _ product: ProductSelect.Product
    ) -> Bool {
        
        switch (self, product.type) {
        case (.account, .account), (.card, .card):
            return true
            
        default:
            return false
        }
    }
}
