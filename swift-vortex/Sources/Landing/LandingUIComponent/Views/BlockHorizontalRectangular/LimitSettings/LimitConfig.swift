//
//  LimitConfig.swift
//  
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import SwiftUI
import SharedConfigs

public struct LimitConfig {
    
    let limit: TextConfig
    let title: TextConfig
    let widthAndHeight: CGFloat
    
    public init(
        limit: TextConfig,
        title: TextConfig,
        widthAndHeight: CGFloat
    ) {
        self.limit = limit
        self.title = title
        self.widthAndHeight = widthAndHeight
    }
}
