//
//  RepeatButtonViewConfig.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

extension RepeatButtonView {
    
    public struct Config {
        
        public let title: String
        public let font: Font
        public let foregroundColor: Color
        public let backgroundColor: Color
        public let action: () -> Void
        
        public init(
            title: String = "Отправить повторно",
            font: Font,
            foregroundColor: Color,
            backgroundColor: Color,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.font = font
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.action = action
        }
    }
}

extension RepeatButtonView.Config {
    
    static let defaultValue: Self = .init(
        font: Font.custom("Inter", size: 12),
        foregroundColor: Color(red: 1, green: 0.21, blue: 0.21),
        backgroundColor: Color(red: 0.96, green: 0.96, blue: 0.97),
        action: {}
    )
}
