//
//  BulletPlaceholderViewConfig.swift
//
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SwiftUI

public struct BulletPlaceholderViewConfig: Equatable {
    
    public let bulletsCount: UInt
    public let color: Color
    public let cornerRadius: CGFloat
    public let frame: CGSize
    public let leadingPadding: CGFloat
    public let sectionCount: UInt
    public let sectionSpacing: CGFloat
    public let spacing: CGFloat
    
    public init(
        bulletsCount: UInt,
        color: Color,
        cornerRadius: CGFloat,
        frame: CGSize,
        leadingPadding: CGFloat,
        sectionCount: UInt,
        sectionSpacing: CGFloat,
        spacing: CGFloat
    ) {
        self.bulletsCount = bulletsCount
        self.color = color
        self.cornerRadius = cornerRadius
        self.frame = frame
        self.leadingPadding = leadingPadding
        self.sectionCount = sectionCount
        self.sectionSpacing = sectionSpacing
        self.spacing = spacing
    }
}
