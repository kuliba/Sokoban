//
//  ProductCard.swift
//
//
//  Created by Igor Malyarov on 25.03.2025.
//

struct ProductCard: Equatable {
    
    let md5Hash: String
    let options: [Option]
    let title: String
    let subtitle: String
}

extension ProductCard {
    
    struct Option: Equatable {
        
        let title: String
        let value: String
    }
}
