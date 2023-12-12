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
}

public extension Config {
    
    struct Background {
        
        let color: Color
    }
}
