//
//  BankDefaultConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct BankDefaultConfig {
    
    let onDisabled: StateConfig
    let offEnabled: StateConfig
    let offDisabled: StateConfig
    
    public init(
        onDisabled: StateConfig, 
        offEnabled: StateConfig, 
        offDisabled: StateConfig
    ) {
        self.onDisabled = onDisabled
        self.offEnabled = offEnabled
        self.offDisabled = offDisabled
    }
}

public extension BankDefaultConfig {
    
    struct StateConfig {
        
        let toggleColor: Color
        
        public init(toggleColor: Color) {
         
            self.toggleColor = toggleColor
        }
    }
}
