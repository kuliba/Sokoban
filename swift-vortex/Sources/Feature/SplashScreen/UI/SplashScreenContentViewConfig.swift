//
//  SplashScreenContentViewConfig.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenContentViewConfig: Equatable {
    
    public let edges: EdgeInsets
    public let footer: Image
    public let footerVPadding: CGFloat
    public let logo: Image
    public let logoSize: CGFloat
    public let spacing: CGFloat
    public let subtextFont: Font
    public let textFont: Font
    
    public init(
        edges: EdgeInsets,
        footer: Image,
        footerVPadding: CGFloat,
        logo: Image,
        logoSize: CGFloat,
        spacing: CGFloat,
        subtextFont: Font,
        textFont: Font
    ) {
        self.edges = edges
        self.footer = footer
        self.footerVPadding = footerVPadding
        self.logo = logo
        self.logoSize = logoSize
        self.spacing = spacing
        self.subtextFont = subtextFont
        self.textFont = textFont
    }
}
