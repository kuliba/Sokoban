//
//  OperatorLabelConfig.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SharedConfigs
import SwiftUI

public struct OperatorLabelConfig: Equatable {
    
    let chevron: ChevronConfig?
    let height: CGFloat
    let title: TextConfig
    let subtitle: TextConfig
    let spacing: CGFloat
    
    public init(
        chevron: ChevronConfig?,
        height: CGFloat,
        title: TextConfig,
        subtitle: TextConfig,
        spacing: CGFloat
    ) {
        self.chevron = chevron
        self.height = height
        self.title = title
        self.subtitle = subtitle
        self.spacing = spacing
    }
}

extension OperatorLabelConfig {
    
    public struct ChevronConfig: Equatable {
        
        public let color: Color
        public let icon: Image
        public let size: CGSize
        
        public init(
            color: Color,
            icon: Image,
            size: CGSize
        ) {
            self.color = color
            self.icon = icon
            self.size = size
        }
    }
}
