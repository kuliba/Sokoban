//
//  ProductSelect+ext.swift
//
//
//  Created by Igor Malyarov on 19.12.2023.
//

import ProductSelectComponent

extension ProductSelect {
    
    static func compact(
        _ selected: Product
    ) -> Self {
        
        .init(selected: selected)
    }
    
    static func expanded(
        _ selected: Product,
        _ products: Products?
    ) -> Self {
        
        .init(selected: selected, products: products)
    }
}
