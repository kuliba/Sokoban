//
//  ProductSelectReducer.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import Foundation

public final class ProductSelectReducer {
    
    public typealias State = ProductSelect
    public typealias Event = ProductSelectEvent
    
    public typealias GetProducts = () -> [ProductSelect.Product]
    
    private let getProducts: GetProducts
    
    public init(getProducts: @escaping GetProducts) {
        
        self.getProducts = getProducts
    }
}

public extension ProductSelectReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var newState = state
        
        switch event {
        case let .select(product):
            guard let product = getProducts()[product.id] else { break }
            
            newState = .init(selected: product)
            
        case .toggleProductSelect:
            switch state.products {
            case .none:
                newState.products = getProducts()
                
            case .some:
                newState.products = nil
            }
        }
        
        return newState
    }
}
