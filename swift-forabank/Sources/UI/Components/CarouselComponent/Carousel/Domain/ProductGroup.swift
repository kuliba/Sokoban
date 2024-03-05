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
