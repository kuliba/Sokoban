//
//  ButtonStateConfig.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

public struct ButtonStateConfig {
    
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
