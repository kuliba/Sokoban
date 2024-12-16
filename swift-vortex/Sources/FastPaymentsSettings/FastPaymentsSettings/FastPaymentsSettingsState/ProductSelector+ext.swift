//
//  ProductSelector+ext.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

public extension UserPaymentSettings.ProductSelector {
    
    func selected(product: Product) -> Self {
        
        .init(selectedProduct: product, products: self.products)
    }
    
    func updated(
        selectedProduct: Product? = nil,
        products: [Product]? = nil,
        status: Status? = nil
    ) -> Self {
        
        .init(
            selectedProduct: selectedProduct ?? self.selectedProduct,
            products: products ?? self.products,
            status: status ?? self.status
        )
    }
}
