//
//  PinCodeConfig.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import SwiftUI

extension PinCodeView {
        
    public struct PinCodeConfig: Equatable {
        
        public let font: Font
        public let foregroundColor: Color
        public let colorsForPin: DotView.ColorsForPin
        
        public init(
            font: Font,
            foregroundColor: Color,
            colorsForPin: DotView.ColorsForPin
        ) {
            
            self.font = font
            self.foregroundColor = foregroundColor
            self.colorsForPin = colorsForPin
        }
    }
}

extension PinCodeView.DotView.ColorsForPin {
    
    static let colorsForDots: Self = .init(
        normal: .gray,
        incorrect: .red,
        correct: .green,
        printing: .blue)
}

extension PinCodeView.PinCodeConfig {
    
    static let defaultValue: Self = .init(
        font: .title,
        foregroundColor: .blue,
        colorsForPin: .colorsForDots
    )
}
