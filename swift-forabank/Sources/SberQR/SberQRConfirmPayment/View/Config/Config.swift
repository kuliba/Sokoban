//
//  Config.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

public struct Config {
    
    let background: Background
    let info: InfoConfig
    let productSelectView: ProductSelectViewConfig
    
    public init(
        background: Background,
        info: InfoConfig,
        productSelectView: ProductSelectViewConfig
    ) {
        self.background = background
        self.info = info
        self.productSelectView = productSelectView
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
