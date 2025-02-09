//
//  CardTypeViewConfig.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SharedConfigs
import SwiftUI

public struct CardTypeViewConfig {
    
    public let title: TextConfig
    public let subtitle: TitleConfig
    
    public init(
        title: TextConfig,
        subtitle: TitleConfig
    ) {
        self.title = title
        self.subtitle = subtitle
    }
}
