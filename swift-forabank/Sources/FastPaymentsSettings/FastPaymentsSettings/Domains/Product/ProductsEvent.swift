//
//  ProductsEvent.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

public extension FastPaymentsSettingsEvent {
    
    typealias ProductUpdateResult = Result<Product.ID, ServiceFailure>
    
    enum ProductsEvent: Equatable {
        
        case selectProduct(Product.ID)
        case toggleProducts
        case updateProduct(ProductUpdateResult)
    }
}
