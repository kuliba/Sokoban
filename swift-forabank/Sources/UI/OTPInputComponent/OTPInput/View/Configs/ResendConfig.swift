//
//  ResendConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct ResendConfig {
    
    let backgroundColor: Color
    let text: TextConfig
    
    public init(
        backgroundColor: Color,
        text: TextConfig
    ) {
        self.backgroundColor = backgroundColor
        self.text = text
    }
}
