//
//  ProductCardConfig.swift
//  
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SharedConfigs
import SwiftUI

public struct ProductCardConfig {
    
    let balance: TextConfig
    let cardSize: CGSize
    let number: TextConfig
    let title: TextConfig
    let shadowColor: Color // main colors/Black background: #1C1C1C;
    let selectedImage: Image
}

public extension ProductSelectConfig.Card {
    
    var productCardConfig: ProductCardConfig {
        
        .init(
            balance: amount,
            cardSize: cardSize,
            number: number,
            title: title,
            shadowColor: .black.opacity(0.1),
            selectedImage: selectedImage
        )
    }
}
