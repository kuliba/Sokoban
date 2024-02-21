//
//  DigitModelConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct DigitModelConfig {
    
    let digitConfig: TextConfig
    let rectColor: Color
    
    public init(
        digitConfig: TextConfig,
        rectColor: Color
    ) {
        self.digitConfig = digitConfig
        self.rectColor = rectColor
    }
}
