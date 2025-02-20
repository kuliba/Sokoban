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
    
    public init(
        labelVPadding: CGFloat,
        imageForegroundColor: Color,
        imageSize: CGSize,
        imagePadding: EdgeInsets,
        hSpacing: CGFloat,
        vSpacing: CGFloat,
        title: TextConfig,
        value: TextConfig
    ) {
        self.labelVPadding = labelVPadding
        self.imageForegroundColor = imageForegroundColor
        self.imageSize = imageSize
        self.imagePadding = imagePadding
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
        self.title = title
        self.value = value
    }
}
