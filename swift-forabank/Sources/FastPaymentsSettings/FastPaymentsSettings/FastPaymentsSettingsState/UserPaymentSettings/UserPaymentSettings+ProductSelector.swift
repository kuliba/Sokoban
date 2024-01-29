//
//  UserPaymentSettings+ProductSelector.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension UserPaymentSettings {
    
    struct ProductSelector: Equatable {
        
        public let selectedProduct: Product?
        public let products: [Product]
        public let status: Status
        
        public init(
            selectedProduct: Product?,
            products: [Product],
            status: Status = .collapsed
        ) {
            self.selectedProduct = selectedProduct
            self.products = products
            self.status = status
        }
        
        public enum Status: Equatable {
            
            case collapsed, expanded
        }
    }
}
