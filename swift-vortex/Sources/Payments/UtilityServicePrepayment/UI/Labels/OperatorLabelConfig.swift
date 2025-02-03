//
//  OperatorLabelConfig.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SharedConfigs
import Foundation

public struct OperatorLabelConfig {
    
    let height: CGFloat
    let title: TextConfig
    let subtitle: TextConfig
    
    public init(
        height: CGFloat,
        title: TextConfig,
        subtitle: TextConfig
    ) {
        self.height = height
        self.title = title
        self.subtitle = subtitle
    }
}
