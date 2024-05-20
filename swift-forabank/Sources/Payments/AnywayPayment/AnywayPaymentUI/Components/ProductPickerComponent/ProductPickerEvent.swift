//
//  ProductPickerEvent.swift
//  
//
//  Created by Igor Malyarov on 21.04.2024.
//

enum ProductPickerEvent: Equatable {
    
    case select(Product)
    case search(String)
}
