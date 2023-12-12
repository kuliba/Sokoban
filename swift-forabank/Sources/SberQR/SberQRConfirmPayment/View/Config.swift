//
//  Config.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

public struct Config {
    
    let background: Background
    let productSelectViewConfig: ProductSelectViewConfig
}

public extension Config {
    
    struct Background {
        
        let color: Color
    }
    
    struct ProductSelectViewConfig {
        
        let amount: TextConfig
        let footer: TextConfig
        let header: TextConfig
        let title: TextConfig
    }
}

public extension Config.ProductSelectViewConfig {
    
    struct TextConfig {
        
        let textFont: Font
        let textColor: Color
    }
}
