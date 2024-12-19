//
//  FooterButtonConfig.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import SharedConfigs
import SwiftUI

public struct FooterButtonConfig {
    
    public let active: ButtonStateConfig
    public let inactive: ButtonStateConfig
    public let tapped: ButtonStateConfig
    public let buttonHeight: CGFloat
    
    public init(
        active: ButtonStateConfig,
        inactive: ButtonStateConfig,
        tapped: ButtonStateConfig,
        buttonHeight: CGFloat = 56
    ) {
        self.active = active
        self.inactive = inactive
        self.tapped = tapped
        self.buttonHeight = buttonHeight
    }
}
