//
//  ProductDetailsState.swift
//  
//
//  Created by Andryusina Nataly on 07.03.2024.
//

import Foundation

public struct ProductDetailsState: Equatable {
    
    public let items: [ListItem]
    public var event: ProductDetailsEvent?
    
    public init(
        items: [ListItem],
        event: ProductDetailsEvent? = nil
    ) {
        self.items = items
        self.event = event
    }
}
