//
//  StatefulButtonConfig.swift
//
//
//  Created by Igor Malyarov on 10.02.2025.
//

import SharedConfigs
import SwiftUI

public struct StatefulButtonConfig {
    
    public let active: _ButtonStateConfig
    public let inactive: _ButtonStateConfig
    public let buttonHeight: CGFloat
    
    public init(
        active: _ButtonStateConfig,
        inactive: _ButtonStateConfig,
        buttonHeight: CGFloat = 56
    ) {
        self.active = active
        self.inactive = inactive
        self.buttonHeight = buttonHeight
    }
}

public struct _ButtonStateConfig: Equatable {
    
    public let backgroundColor: Color
    public let title: TitleConfig
    
    public init(
        backgroundColor: Color,
        title: TitleConfig
    ) {
        self.backgroundColor = backgroundColor
        self.title = title
    }
}
