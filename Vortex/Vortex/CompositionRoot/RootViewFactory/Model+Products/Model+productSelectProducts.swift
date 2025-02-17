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
            .compactMap {
                
                $0.productSelectProduct(
                    formatBalance: { [weak self] in
                        
                        self?.formattedBalance(of: $0) ?? ""
                    },
                    getImage: { [weak self] in
                        
                        self?.images.value[$0]?.image
                    }
                )
            }
    }
    
    func sbpLinkedProduct() -> ProductSelect.Product? {
    
        nil // TODO: FIXME
    }
    
    func c2gProductSelectProducts() -> [ProductSelect.Product] {
        
        return c2gPaymentEligibleProducts()
            .compactMap {
                
                $0.productSelectProduct(
                    formatBalance: { [weak self] in
                        
                        self?.formattedBalance(of: $0) ?? ""
                    },
                    getImage: { [weak self] in
                        
                        self?.images.value[$0]?.image
                    }
                )
            }
    }
}
