//
//  RoundedConfig.swift
//  
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import SwiftUI

public struct RoundedConfig: Equatable {
    
    public let padding: CGFloat
    public let cornerRadius: CGFloat
    public let background: Color
    
    public init(
        padding: CGFloat,
        cornerRadius: CGFloat,
        background: Color
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.background = background
    }
}
