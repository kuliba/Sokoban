//
//  ErrorConfig.swift
//
//
//  Created by Дмитрий Савушкин on 24.07.2024.
//

import SharedConfigs
import SwiftUI

public struct ErrorConfig {
    
    public let title: String
    public let titleConfig: TextConfig
    public let icon: Image
    public let iconForeground: Color
    public let backgroundIcon: Color
    
    public init(
        title: String,
        titleConfig: TextConfig,
        icon: Image,
        iconForeground: Color,
        backgroundIcon: Color
    ) {
        self.title = title
        self.titleConfig = titleConfig
        self.icon = icon
        self.iconForeground = iconForeground
        self.backgroundIcon = backgroundIcon
    }
}
