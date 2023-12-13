//
//  ProductSelectReducer.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import Foundation

public final class ProductSelectReducer {
    
    public typealias State = ProductSelect
    public typealias Event = SberQRConfirmPaymentEvent.ProductSelectEvent
    
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
        case let .select(id):
            guard let product = getProducts().first(where: { $0.id == id })
            else { break }
            
            newState = .compact(product)
            
        case .toggleProductSelect:
            switch state {
            case let .compact(product):
                newState = .expanded(product, getProducts())
                
            case let .expanded(selected, _):
                newState = .compact(selected)
            }
        }
        
        return newState
    }
}
