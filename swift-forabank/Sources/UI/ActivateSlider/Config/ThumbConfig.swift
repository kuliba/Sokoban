//
//  ThumbConfig.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

public struct ThumbConfig {
    
    let icon: Image
    let color: Color
    let backgroundColor: Color
    let isAnimated: Bool

    public init(
        icon: Image,
        color: Color,
        backgroundColor: Color,
        isAnimated: Bool
    ) {
        self.icon = icon
        self.color = color
        self.backgroundColor = backgroundColor
        self.isAnimated = isAnimated
    }
}
