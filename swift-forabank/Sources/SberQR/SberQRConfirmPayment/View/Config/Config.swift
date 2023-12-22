//
//  Config.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import ProductSelectComponent
import SwiftUI

public struct Config {

    let amount: AmountConfig
    let background: Background
    let button: ButtonConfig
    let info: InfoConfig
    let productSelect: ProductSelectConfig
    
    public init(
        amount: AmountConfig,
        background: Background,
        button: ButtonConfig,
        info: InfoConfig,
        productSelect: ProductSelectConfig
    ) {
        self.amount = amount
        self.background = background
        self.button = button
        self.info = info
        self.productSelect = productSelect
    }
}

public extension Config {
    
    struct Background {
        
        let color: Color
        
        public init(color: Color) {
         
            self.color = color
        }
    }
}
