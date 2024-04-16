//
//  PaymentContractConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct PaymentContractConfig {
    
    let active: StateConfig
    let inactive: StateConfig
    
    public init(
        active: StateConfig,
        inactive: StateConfig
    ) {
        self.active = active
        self.inactive = inactive
    }
}

public extension PaymentContractConfig {
    
    struct StateConfig {
        
        let title: TextConfig
        let toggleColor: Color
        let subtitle: TextConfig
        
        public init(
            title: TextConfig,
            toggleColor: Color,
            subtitle: TextConfig
        ) {
            self.title = title
            self.toggleColor = toggleColor
            self.subtitle = subtitle
        }
    }
}
