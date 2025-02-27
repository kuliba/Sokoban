//
//  Model+productSelectProducts.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.05.2024.
//

import ProductSelectComponent

extension Model {
    
    func productSelectProducts() -> [ProductSelect.Product] {
        
        return paymentEligibleProducts()
            .compactMap(productSelectProduct)
    }
    
    func c2gProductSelectProducts() -> [ProductSelect.Product] {
        
        return c2gPaymentEligibleProducts()
            .compactMap(productSelectProduct)
    }
    
    func productSelectProduct(
        for data: ProductData
    ) -> ProductSelect.Product? {
        
        data.productSelectProduct(
            formatBalance: { [weak self] in
                
                self?.formattedBalance(of: $0) ?? ""
            },
            getImage: { [weak self] in
                
                self?.images.value[$0]?.image
            }
        )
    }
}
