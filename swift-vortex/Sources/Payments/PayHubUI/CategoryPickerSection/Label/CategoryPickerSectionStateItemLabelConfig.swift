//
//  CategoryPickerSectionStateItemLabelConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SharedConfigs
import SwiftUI

public struct CategoryPickerSectionStateItemLabelConfig: Equatable {
    
    public let iconBackground: IconBackground
    public let iconSize: CGSize
    public let placeholder: Placeholder
    public let spacing: CGFloat
    public let title: TextConfig
    public let showAll: TitleConfig
    
    public init(
        iconBackground: IconBackground,
        iconSize: CGSize,
        placeholder: Placeholder,
        spacing: CGFloat,
        title: TextConfig,
        showAll: TitleConfig
    ) {
        self.iconBackground = iconBackground
        self.iconSize = iconSize
        self.placeholder = placeholder
        self.spacing = spacing
        self.title = title
        self.showAll = showAll
    }
}

extension CategoryPickerSectionStateItemLabelConfig {
    
    public struct IconBackground: Equatable {
        
        public let color: Color
        public let roundedRect: RoundedRect
        
        public init(
            color: Color,
            roundedRect: RoundedRect
        ) {
            self.color = color
            self.roundedRect = roundedRect
        }
    }
    
    public struct Placeholder: Equatable {
        
        public let icon: RoundedRect
        public let title: RoundedRect
        public let spacing: CGFloat
        
        public init(
            icon: RoundedRect,
            title: RoundedRect,
            spacing: CGFloat
        ) {
            self.icon = icon
            self.title = title
            self.spacing = spacing
        }
    }
    
    public struct RoundedRect: Equatable {
        
        public let radius: CGFloat
        public let size: CGSize
        
        public init(
            radius: CGFloat,
            size: CGSize
        ) {
            self.radius = radius
            self.size = size
        }
    }
}
