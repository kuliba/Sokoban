//
//  ResendConfig.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI
import UIPrimitives

public struct ResendConfig {
    
    public let backgroundColor: Color
    public let text: TextConfig
    
    public init(
        backgroundColor: Color,
        text: TextConfig
    ) {
        self.backgroundColor = backgroundColor
        self.text = text
    }
}
