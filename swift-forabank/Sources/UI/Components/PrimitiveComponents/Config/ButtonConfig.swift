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
    
    public init(
        active: ButtonStateConfig,
        inactive: ButtonStateConfig
    ) {
        self.active = active
        self.inactive = inactive
    }
}
