//
//  ProductGroup.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import Foundation

public struct ProductGroup: Equatable, Identifiable {
    
    public typealias ID = Product.ID.ProductType

    public let id: ID
    
    let products: [Product]
    var state: State
    
    public init(
        id: ID,
        products: [Product],
        state: State = .collapsed
    ) {
        self.id = id
        self.products = products
        self.state = state
    }
    
    public enum State {
        
        case collapsed, expanded
    }
}

extension ProductGroup {
    
    func visibleProducts(count: Int) -> [Product] {
        
        switch state {
        case .collapsed:
            return .init(products.prefix(count))
            
        case .expanded:
            return products
        }
    }
    
    func spoilerTitle(count: Int) -> String? {
        
        switch state {
        case .collapsed:
            let numberIfItemsUnderSpoiler = products.count - count
            
            guard numberIfItemsUnderSpoiler > 0
            else { return nil }
            
            return "+\(numberIfItemsUnderSpoiler)"
            
        case .expanded:
            return nil
        }
    }
}
