//
//  ProductSelectViewConfig.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

public struct ProductSelectViewConfig {
    
    let amount: TextConfig
    let card: Card
    let footer: TextConfig
    let header: TextConfig
    let title: TextConfig
}

public extension ProductSelectViewConfig {
    
    struct TextConfig {
        
        let textFont: Font
        let textColor: Color
    }

    struct Card {
        
        let amount: TextConfig
        let number: TextConfig
        let title: TextConfig
    }
}
