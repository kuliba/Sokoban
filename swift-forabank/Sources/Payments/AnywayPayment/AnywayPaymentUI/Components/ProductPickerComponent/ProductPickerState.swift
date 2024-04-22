//
//  ProductPickerState.swift
//  
//
//  Created by Igor Malyarov on 21.04.2024.
//

struct ProductPickerState: Equatable {
    
    var selection: Product?
    var options: Options?
}

extension ProductPickerState {
    
    struct Options: Equatable {
        
        var products: [Product]
        var search: String
    }
}
