//
//  ProductCardViewConfig.swift
//
//
//  Created by Igor Malyarov on 25.03.2025.
//

import SwiftUI
import UIPrimitives

public struct ProductCardViewConfig: Equatable {
    
    public let backgroundColor: Color
    public let cornerRadius: CGFloat
    public let edges: EdgeInsets
    public let spacing: CGFloat
    public let header: HeaderConfig
    public let label: LabelConfig
    
    public init(
        backgroundColor: Color,
        cornerRadius: CGFloat,
        edges: EdgeInsets,
        spacing: CGFloat,
        header: HeaderConfig,
        label: LabelConfig
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.edges = edges
        self.spacing = spacing
        self.header = header
        self.label = label
    }
}

extension ProductCardViewConfig {
    
    public struct HeaderConfig: Equatable {
        
        public let title: TextConfig
        public let subtitle: TextConfig
        public let spacing: CGFloat
        
        public init(
            title: TextConfig,
            subtitle: TextConfig,
            spacing: CGFloat
        ) {
            self.title = title
            self.subtitle = subtitle
            self.spacing = spacing
        }
    }
    
    public struct LabelConfig: Equatable {
        
        public let icon: IconConfig
        public let option: OptionConfig
        public let title: TitleConfig
        public let spacing: CGFloat
        
        public init(
            icon: IconConfig,
            option: OptionConfig,
            title: TitleConfig,
            spacing: CGFloat
        ) {
            self.icon = icon
            self.option = option
            self.title = title
            self.spacing = spacing
        }
    }
}

extension ProductCardViewConfig.LabelConfig {
    
    public struct IconConfig: Equatable {
        
        public let cornerRadius: CGFloat
        public let limit: TextConfig
        public let limitPadding: CGFloat
        public let shadow: ShadowConfig
        public let size: CGSize
        
        public init(
            cornerRadius: CGFloat,
            limit: TextConfig,
            limitPadding: CGFloat,
            shadow: ShadowConfig,
            size: CGSize
        ) {
            self.cornerRadius = cornerRadius
            self.limit = limit
            self.limitPadding = limitPadding
            self.shadow = shadow
            self.size = size
        }
    }
    
    public struct OptionConfig: Equatable {
        
        public let icon: Image
        public let iconColor: Color
        public let iconSize: CGFloat
        public let spacing: CGFloat
        public let title: TextConfig
        public let value: TextConfig
        public let valueSpacing: CGFloat
        
        public init(
            icon: Image,
            iconColor: Color,
            iconSize: CGFloat,
            spacing: CGFloat,
            title: TextConfig,
            value: TextConfig,
            valueSpacing: CGFloat
        ) {
            self.icon = icon
            self.iconColor = iconColor
            self.iconSize = iconSize
            self.spacing = spacing
            self.title = title
            self.value = value
            self.valueSpacing = valueSpacing
        }
    }
    
#warning("Remove")
    public struct TitleConfig: Equatable {
        
        public let spacing: CGFloat
        
        public init(
            spacing: CGFloat
        ) {
            self.spacing = spacing
        }
    }
}

extension ProductCardViewConfig.LabelConfig.IconConfig {
    
    public struct ShadowConfig: Equatable {
        
        public let color: Color
        public let offset: CGFloat
        public let blur: CGFloat
        public let size: CGSize
        
        public init(
            color: Color,
            offset: CGFloat,
            blur: CGFloat,
            size: CGSize
        ) {
            self.color = color
            self.offset = offset
            self.blur = blur
            self.size = size
        }
    }
}
