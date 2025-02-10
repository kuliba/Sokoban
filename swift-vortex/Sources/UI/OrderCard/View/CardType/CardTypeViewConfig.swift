//
//  CardTypeViewConfig.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SharedConfigs
import SwiftUI

public struct CardTypeViewConfig {
    
    public let backgroundColorIcon: Color
    public let icon: Image
    public let subtitle: TitleConfig
    public let title: TextConfig
    
    public init(
        backgroundColorIcon: Color,
        icon: Image,
        subtitle: TitleConfig,
        title: TextConfig
    ) {
        self.backgroundColorIcon = backgroundColorIcon
        self.icon = icon
        self.subtitle = subtitle
        self.title = title
    }
}
