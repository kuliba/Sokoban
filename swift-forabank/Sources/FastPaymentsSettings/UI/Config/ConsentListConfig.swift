//
//  ConsentListConfig.swift
//  
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct ConsentListConfig {
    
    let errorIcon: ErrorIcon
    let title: TextConfig
}

public extension ConsentListConfig {
    
    struct ErrorIcon {
        
        let backgroundColor: Color
        let image: Image
    }
}
