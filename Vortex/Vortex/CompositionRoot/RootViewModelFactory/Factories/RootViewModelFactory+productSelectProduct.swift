//
//  RootViewModelFactory+productSelectProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import ProductSelectComponent

extension RootViewModelFactory {
    
    @inlinable
    func productSelectProduct(
        forID id: Int
    ) -> ProductSelect.Product? {
        
        guard let product = model.product(productId: id) else { return nil }
        
        return productSelectProduct(for: product)
    }
    
    @inlinable
    func productSelectProduct(
        for product: ProductData
    ) -> ProductSelect.Product? {
        
        return model.productSelectProduct(for: product)
    }
}
