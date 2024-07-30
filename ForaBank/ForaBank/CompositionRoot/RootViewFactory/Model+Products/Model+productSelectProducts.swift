//
//  Model+productSelectProducts.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.05.2024.
//

import ProductSelectComponent

extension Model {
    
    func productSelectProducts() -> [ProductSelect.Product] {
        
        return paymentProducts()
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
    
    func productSelectProductsForSberQR(
    ) -> [ProductSelect.Product] {
        
        return paymentProductsForSberQR()
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
