//
//  DetailCellViewConfig.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI
import SharedConfigs

public struct DetailCellViewConfig: Equatable {
    
    public let labelVPadding: CGFloat
    public let imageForegroundColor: Color
    public let imageSize: CGSize
    public let imagePadding: EdgeInsets
    public let hSpacing: CGFloat
    public let vSpacing: CGFloat
    public let title: TextConfig
    public let value: TextConfig
    public let product: ProductConfig
    
    public init(
        labelVPadding: CGFloat,
        imageForegroundColor: Color,
        imageSize: CGSize,
        imagePadding: EdgeInsets,
        hSpacing: CGFloat,
        vSpacing: CGFloat,
        title: TextConfig,
        value: TextConfig,
        product: ProductConfig
    ) {
        self.labelVPadding = labelVPadding
        self.imageForegroundColor = imageForegroundColor
        self.imageSize = imageSize
        self.imagePadding = imagePadding
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
        self.title = title
        self.value = value
        self.product = product
    }
    
    public struct ProductConfig: Equatable {
        
        public let balance: TextConfig
        public let balanceTrailingPadding: CGFloat
        public let description: TextConfig
        public let hSpacing: CGFloat
        public let iconSize: CGSize
        public let name: TextConfig
        public let title: TextConfig
        public let vStackVPadding: CGFloat
        
        public init(
            balance: TextConfig,
            balanceTrailingPadding: CGFloat,
            description: TextConfig,
            hSpacing: CGFloat,
            iconSize: CGSize,
            name: TextConfig,
            title: TextConfig,
            vStackVPadding: CGFloat
        ) {
            self.balance = balance
            self.balanceTrailingPadding = balanceTrailingPadding
            self.description = description
            self.hSpacing = hSpacing
            self.iconSize = iconSize
            self.name = name
            self.title = title
            self.vStackVPadding = vStackVPadding
        }
    }
}
