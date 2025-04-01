//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 31.03.2025.
//

import SwiftUI

public struct ConsentPlaceholderViewConfig: Equatable {
    
    public let circleFrame: CGSize
    public let color: Color
    public let cornerRadius: CGFloat
    public let count: UInt
    public let frameHeight: CGFloat
    public let height: CGFloat
    public let spacing: CGFloat
    
    public init(
        circleFrame: CGSize,
        color: Color,
        cornerRadius: CGFloat,
        count: UInt,
        frameHeight: CGFloat,
        height: CGFloat,
        spacing: CGFloat
    ) {
        self.circleFrame = circleFrame
        self.color = color
        self.cornerRadius = cornerRadius
        self.count = count
        self.frameHeight = frameHeight
        self.height = height
        self.spacing = spacing
    }
}
