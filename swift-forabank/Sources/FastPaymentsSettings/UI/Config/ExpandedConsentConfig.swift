//
//  ExpandedConsentConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct ExpandedConsentConfig {
    
    let apply: Apply
    let bank: TextConfig
    let checkmark: CheckmarkConfig
}

public extension ExpandedConsentConfig {
    
    struct Apply {
        
        let backgroundColor: Color
        let title: TextConfig
    }
    
    struct CheckmarkConfig {
        
        let backgroundColor: Color
        let borderColor: Color
        let color: Color
        let image: Image
    }
}
