//
//  TimerViewConfig.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

extension TimerView {
    
    public struct Config {
        
        public let descFont: Font
        public let descForegroundColor: Color
        public let valueFont: Font
        public let valueForegroundColor: Color
        
        public init(
            descFont: Font,
            descForegroundColor: Color,
            valueFont: Font,
            valueForegroundColor: Color
        ) {
            
            self.descFont = descFont
            self.descForegroundColor = descForegroundColor
            self.valueFont = valueFont
            self.valueForegroundColor = valueForegroundColor
        }
    }
}

extension TimerView.Config {
    
    static let defaultConfig: Self = .init(
        descFont: .custom("Inter", size: 14),
        descForegroundColor: Color(red: 0.6, green: 0.6, blue: 0.6),
        valueFont: .custom("Inter", size: 18),
        valueForegroundColor: Color(red: 0.11, green: 0.11, blue: 0.11)
    )
}
