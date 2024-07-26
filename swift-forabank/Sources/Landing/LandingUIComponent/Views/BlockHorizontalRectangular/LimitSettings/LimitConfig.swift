//
//  LimitConfig.swift
//  
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import SwiftUI
import SharedConfigs

struct LimitConfig {
    
    let limit: TextConfig
    let backgroundColor: Color
    let title: TextConfig
    let widthAndHeight: CGFloat
    init(
        limit: TextConfig,
        backgroundColor: Color,
        title: TextConfig,
        widthAndHeight: CGFloat
    ) {
        self.limit = limit
        self.backgroundColor = backgroundColor
        self.title = title
        self.widthAndHeight = widthAndHeight
    }
}
