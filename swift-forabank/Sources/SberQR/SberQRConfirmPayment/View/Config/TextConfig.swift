//
//  TextConfig.swift
//  
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

public struct TextConfig {
    
    let textFont: Font
    let textColor: Color
    
    public init(textFont: Font, textColor: Color) {
     
        self.textFont = textFont
        self.textColor = textColor
    }
}
