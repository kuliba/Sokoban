//
//  DescriptorViewConfig.swift
//  
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SharedConfigs
import SwiftUI

public struct DescriptorViewConfig: Equatable {
    
    public let background: Color
    public let cornerRadius: CGFloat
    public let edges: EdgeInsets
    public let header: Header
    public let item: Item
    public let placeholderColor: Color
    public let placeholderCount: Int
    public let spacing: CGFloat
    
    public init(
        background: Color,
        cornerRadius: CGFloat,
        edges: EdgeInsets,
        header: Header,
        item: Item,
        placeholderColor: Color,
        placeholderCount: Int,
        spacing: CGFloat
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.edges = edges
        self.header = header
        self.item = item
        self.placeholderColor = placeholderColor
        self.placeholderCount = placeholderCount
        self.spacing = spacing
    }
}

extension DescriptorViewConfig {
    
    public struct Header: Equatable {
        
        public let height: CGFloat
        public let placeholder: Placeholder
        public let title: TextConfig
        
        public init(
            height: CGFloat,
            placeholder: Placeholder,
            title: TextConfig
        ) {
            self.height = height
            self.placeholder = placeholder
            self.title = title
        }
    }
    
    public struct Item: Equatable {
        
        public let height: CGFloat
        public let iconFrame: CGSize
        public let spacing: CGFloat
        public let title: TextConfig
        public let value: TextConfig
        public let vSpacing: CGFloat
        public let placeholder: Placeholder
        
        public init(
            height: CGFloat,
            iconFrame: CGSize,
            spacing: CGFloat,
            title: TextConfig,
            value: TextConfig,
            vSpacing: CGFloat,
            placeholder: Placeholder
        ) {
            self.height = height
            self.iconFrame = iconFrame
            self.spacing = spacing
            self.title = title
            self.value = value
            self.vSpacing = vSpacing
            self.placeholder = placeholder
        }
    }
}

extension DescriptorViewConfig.Header {
    
    public struct Placeholder: Equatable {
        
        public let color: Color
        public let cornerRadius: CGFloat
        public let height: CGFloat
        
        public init(
            color: Color,
            cornerRadius: CGFloat,
            height: CGFloat
        ) {
            self.color = color
            self.cornerRadius = cornerRadius
            self.height = height
        }
    }
}

extension DescriptorViewConfig.Item {
    
    public struct Placeholder: Equatable {
        
        public let color: Color
        public let cornerRadius: CGFloat
        public let titleHeight: CGFloat
        public let valueHeight: CGFloat
        
        public init(
            color: Color,
            cornerRadius: CGFloat,
            titleHeight: CGFloat,
            valueHeight: CGFloat
        ) {
            self.color = color
            self.cornerRadius = cornerRadius
            self.titleHeight = titleHeight
            self.valueHeight = valueHeight
        }
    }
}
