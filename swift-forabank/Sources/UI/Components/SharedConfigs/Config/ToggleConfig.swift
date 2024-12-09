//
//  ToggleConfig.swift
//
//
//  Created by Valentin Ozerov on 09.12.2024.
//

import SwiftUI

public struct ToggleConfig {
    
    public let size: CGSize
    public let padding: CGFloat
    public let lineWidth: CGFloat
    public let colors: Colors
    
    public struct Colors {
        
        public let on: Color
        public let off: Color
        
        public init(on: Color, off: Color) {
            self.on = on
            self.off = off
        }
    }
    
    public init(
        size: CGSize = .init(width: 51, height: 31),
        padding: CGFloat = 5,
        lineWidth: CGFloat = 1,
        colors: Colors
    ) {
        self.size = size
        self.padding = padding
        self.lineWidth = lineWidth
        self.colors = colors
    }
}

public extension ToggleConfig {
    
    static let preview = Self(
        size: .init(width: 51, height: 31),
        padding: 5,
        lineWidth: 1,
        colors: .init(
            on: .green,
            off: .black
        )
    )
}
