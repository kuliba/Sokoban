//
//  ButtonConfig.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

public struct ButtonConfig {
    
    public let active: ButtonStateConfig
    public let inactive: ButtonStateConfig
    public let buttonHeight: CGFloat
    
    public init(
        active: ButtonStateConfig,
        inactive: ButtonStateConfig,
        buttonHeight: CGFloat = 56
    ) {
        self.active = active
        self.inactive = inactive
        self.buttonHeight = buttonHeight
    }
}
