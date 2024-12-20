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
    let noMatch: NoSearchMatchConfig
    
    public init(
        apply: Apply,
        bank: TextConfig,
        checkmark: CheckmarkConfig,
        noMatch: NoSearchMatchConfig
    ) {
        self.apply = apply
        self.bank = bank
        self.checkmark = checkmark
        self.noMatch = noMatch
    }
}

public extension ExpandedConsentConfig {
    
    struct Apply {
        
        let backgroundColor: Color
        let title: TextConfig
        
        public init(
            backgroundColor: Color,
            title: TextConfig
        ) {
            self.backgroundColor = backgroundColor
            self.title = title
        }
    }
    
    struct CheckmarkConfig {
        
        let backgroundColor: Color
        let borderColor: Color
        let color: Color
        let image: Image
        
        public init(
            backgroundColor: Color,
            borderColor: Color,
            color: Color,
            image: Image
        ) {
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.color = color
            self.image = image
        }
    }
    
    struct NoSearchMatchConfig {
        
        let image: LogoConfig
        let title: TextConfig
        
        public init(
            image: LogoConfig,
            title: TextConfig
        ) {
            self.image = image
            self.title = title
        }
    }
}
