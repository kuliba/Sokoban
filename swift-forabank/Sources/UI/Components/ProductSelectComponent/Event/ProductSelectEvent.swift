//
//  ProductSelectEvent.swift
//  
//
//  Created by Igor Malyarov on 22.12.2023.
//

public enum ProductSelectEvent: Equatable {
    
    case toggleProductSelect
    case select(ProductSelect.Product)
}
