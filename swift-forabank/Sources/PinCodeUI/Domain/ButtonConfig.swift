//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 03.07.2023.
//

import SwiftUI

public struct ButtonConfig: Equatable {
    
    public let font: Font
    public let textColor: Color
    public let buttonColor: Color
    
    public init(font: Font, textColor: Color, buttonColor: Color) {
        
        self.font = font
        self.textColor = textColor
        self.buttonColor = buttonColor
    }
}

extension ButtonConfig {
    
    static let defaultConfig: Self = .init(
        font: .title,
        textColor: .black,
        buttonColor: .gray
    )
}
