//
//  ProductSelect.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

public struct ProductSelect: Equatable {
    
    // TODO: replace Array with NonEmpty
    public typealias Products = [Product]
    
    public var selected: Product?
    var products: Products? = nil
    
    public init(
        selected: Product?,
        products: Products? = nil
    ) {
        self.selected = selected
        self.products = products
    }
}
