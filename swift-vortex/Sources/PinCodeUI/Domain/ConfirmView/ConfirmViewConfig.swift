//
//  ConfirmViewConfig.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

extension ConfirmView {
    
    public struct Config {
        
        public let font: Font
        public let foregroundColor: Color
        
        public init(
            font: Font,
            foregroundColor: Color
        ) {
            
            self.font = font
            self.foregroundColor = foregroundColor
        }
    }
}

public extension ConfirmView.Config {
    
    static let defaultConfig: Self = .init(
        font: Font.custom("Inter", size: 18).weight(.semibold),
        foregroundColor: Color(red: 0.11, green: 0.11, blue: 0.11)
    )
}

