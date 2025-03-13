//
//  SplashScreenContentViewConfig.swift
//  
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenContentViewConfig: Equatable {
    
    public let logo: Image
    public let logoSize: CGFloat
    public let name: Image
    public let nameColor: Color
    public let nameVPadding: CGFloat
    public let spacing: CGFloat
    public let textFont: Font
    public let subtextFont: Font
    public let edges: EdgeInsets
    
    public init(
        logo: Image,
        logoSize: CGFloat,
        name: Image,
        nameColor: Color,
        nameVPadding: CGFloat,
        spacing: CGFloat,
        textFont: Font,
        subtextFont: Font,
        edges: EdgeInsets
    ) {
        self.logo = logo
        self.logoSize = logoSize
        self.name = name
        self.nameColor = nameColor
        self.nameVPadding = nameVPadding
        self.spacing = spacing
        self.textFont = textFont
        self.subtextFont = subtextFont
        self.edges = edges
    }
}
