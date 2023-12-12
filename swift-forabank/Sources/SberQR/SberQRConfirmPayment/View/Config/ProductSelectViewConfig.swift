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
    
    public init(
        amount: TextConfig,
        card: Card,
        footer: TextConfig,
        header: TextConfig,
        title: TextConfig
    ) {
        self.amount = amount
        self.card = card
        self.footer = footer
        self.header = header
        self.title = title
    }
}

public extension ProductSelectViewConfig {
    
    struct Card {
        
        let amount: TextConfig
        let number: TextConfig
        let title: TextConfig
        
        public init(
            amount: TextConfig,
            number: TextConfig,
            title: TextConfig
        ) {
            self.amount = amount
            self.number = number
            self.title = title
        }
    }
}
