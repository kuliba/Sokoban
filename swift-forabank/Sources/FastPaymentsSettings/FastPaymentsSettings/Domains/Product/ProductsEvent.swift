//
//  ProductsEvent.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public typealias ProductUpdateResult = Result<Product.ID, ServiceFailure>

public enum ProductsEvent: Equatable {
    
    case selectProduct(Product.ID)
    case toggleProducts
    case updateProduct(ProductUpdateResult)
}
