//
//  TopUpViewConfig.swift
//  
//
//  Created by Andryusina Nataly on 23.02.2025.
//

import SharedConfigs
import SwiftUI

public struct TopUpViewConfig {

    public let description: TitleConfig
    public let icon: Image
    public let iconSize: CGSize
    public let placeholder: Color
    public let spacing: CGFloat
    public let subtitle: TitleConfig
    public let title: TitleConfig
    public let toggle: SharedConfigs.ToggleConfig
    public let shimmering: Color

    
    public init(
        description: TitleConfig,
        icon: Image,
        iconSize: CGSize,
        placeholder: Color,
        spacing: CGFloat,
        subtitle: TitleConfig,
        title: TitleConfig,
        toggle: SharedConfigs.ToggleConfig,
        shimmering: Color
    ) {
        self.description = description
        self.icon = icon
        self.iconSize = iconSize
        self.placeholder = placeholder
        self.spacing = spacing
        self.subtitle = subtitle
        self.title = title
        self.toggle = toggle
        self.shimmering = shimmering
    }
}
