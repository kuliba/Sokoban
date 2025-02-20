//
//  DetailCellViewConfig.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI
import SharedConfigs

public struct DetailCellViewConfig: Equatable {
    
    public let insets: EdgeInsets
    public let imageSize: CGSize
    public let imageTopPadding: CGFloat
    public let hSpacing: CGFloat
    public let vSpacing: CGFloat
    public let title: TextConfig
    public let value: TextConfig
    
    public init(
        insets: EdgeInsets,
        imageSize: CGSize,
        imageTopPadding: CGFloat,
        hSpacing: CGFloat,
        vSpacing: CGFloat,
        title: TextConfig,
        value: TextConfig
    ) {
        self.insets = insets
        self.imageSize = imageSize
        self.imageTopPadding = imageTopPadding
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
        self.title = title
        self.value = value
    }
}
