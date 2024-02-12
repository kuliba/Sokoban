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
    
    public init(
        apply: Apply,
        bank: TextConfig,
        checkmark: CheckmarkConfig
    ) {
        self.apply = apply
        self.bank = bank
        self.checkmark = checkmark
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
}
