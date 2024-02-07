//
//  ProductsEvent.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public enum ProductsEvent: Equatable {
    
    case selectProduct(SelectableProductID)
    case toggleProducts
    case updateProduct(ProductUpdateResult)
}

public extension ProductsEvent {
    
    typealias ProductUpdateResult = Result<SelectableProductID, ServiceFailure>
    
}
