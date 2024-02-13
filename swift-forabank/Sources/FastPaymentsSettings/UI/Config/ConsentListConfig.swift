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
    let collapsedBankList: TextConfig
    let errorIcon: ErrorIcon
    let expandedConsent: ExpandedConsentConfig
    let image: Image
    let title: TextConfig
    
    public init(
        chevron: Chevron,
        collapsedBankList: TextConfig,
        errorIcon: ErrorIcon,
        expandedConsent: ExpandedConsentConfig,
        image: Image,
        title: TextConfig
    ) {
        self.chevron = chevron
        self.collapsedBankList = collapsedBankList
        self.errorIcon = errorIcon
        self.expandedConsent = expandedConsent
        self.image = image
        self.title = title
    }
}

public extension ConsentListConfig {
    
    struct Chevron {
        
        let image: Image
        let color: Color
        let title: TextConfig
        
        public init(
            image: Image,
            color: Color,
            title: TextConfig
        ) {
            self.image = image
            self.color = color
            self.title = title
        }
    }
    
    struct ErrorIcon {
        
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
}
