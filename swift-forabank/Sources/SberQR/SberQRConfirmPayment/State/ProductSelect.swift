//
//  ProductSelect.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

public enum ProductSelect: Equatable {
    
    case compact(Product)
    case expanded(Product, [Product])
}
