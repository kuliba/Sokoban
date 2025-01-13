//
//  OperatorLabelConfig.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SharedConfigs

public struct OperatorLabelConfig {
    
    let title: TextConfig
    let subtitle: TextConfig
    
    public init(
        title: TextConfig,
        subtitle: TextConfig
    ) {
        self.title = title
        self.subtitle = subtitle
    }
}
