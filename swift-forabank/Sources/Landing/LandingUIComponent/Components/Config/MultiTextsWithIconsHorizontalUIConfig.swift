//
//  MultiTextsWithIconsHorizontalUIConfig.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

import SwiftUI

public extension Landing.MultiTextsWithIconsHorizontal {
    
    struct Config: Equatable {
        
        public let color: Color
        public let font: Font
        
        public init(color: Color, font: Font) {
            self.color = color
            self.font = font
        }
    }
}
