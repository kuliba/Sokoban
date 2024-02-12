//
//  BankDefaultConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct BankDefaultConfig {
    
    let logo: LogoConfig
    let title: TextConfig
    let toggleConfig: ToggleConfig
    let subtitle: TextConfig
    
    public init(
        logo: LogoConfig,
        title: TextConfig,
        toggleConfig: ToggleConfig,
        subtitle: TextConfig
    ) {
        self.logo = logo
        self.title = title
        self.toggleConfig = toggleConfig
        self.subtitle = subtitle
    }
}

public extension BankDefaultConfig {
    
    struct LogoConfig {
        
        let backgroundColor: Color
        let image: Image
        
        public init(
            backgroundColor: Color,
            image: Image
        ) {
            self.backgroundColor = backgroundColor
            self.image = image
        }
    }
    
    struct ToggleConfig {
        
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
    
    struct StateConfig {
        
        let toggleColor: Color
        
        public init(toggleColor: Color) {
            
            self.toggleColor = toggleColor
        }
    }
}
