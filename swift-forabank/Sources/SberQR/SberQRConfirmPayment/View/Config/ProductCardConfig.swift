//
//  ProductCardConfig.swift
//  
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SwiftUI

struct ProductCardConfig {
    
    let balance: TextConfig
    let number: TextConfig
    let title: TextConfig
    let shadowColor: Color // main colors/Black background: #1C1C1C;
}

extension ProductSelectConfig.Card {
    
    var productCardConfig: ProductCardConfig {
        
        .init(
            balance: amount,
            number: number,
            title: title,
            shadowColor: .black.opacity(0.1)
        )
    }
}
