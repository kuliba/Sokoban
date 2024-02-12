//
//  ConsentListConfig.swift
//  
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct ConsentListConfig {
    
    let chevron: Chevron
    let errorIcon: ErrorIcon
    let title: TextConfig
}

public extension ConsentListConfig {
    
    struct Chevron {
        
        let image: Image
        let color: Color
        let title: TextConfig
    }
    
    struct ErrorIcon {
        
        let backgroundColor: Color
        let image: Image
    }
}
