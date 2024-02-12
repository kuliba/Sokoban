//
//  ExpandedConsentConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

public struct ExpandedConsentConfig {
    
    let checkmark: CheckmarkConfig
}

public extension ExpandedConsentConfig {
    
    struct CheckmarkConfig {
        
        let backgroundColor: Color
        let borderColor: Color
        let color: Color
        let image: Image
    }
}
