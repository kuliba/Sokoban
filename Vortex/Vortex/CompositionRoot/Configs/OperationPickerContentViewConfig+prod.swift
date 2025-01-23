//
//  OperationPickerContentViewConfig+prod.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import Foundation
import PayHubUI

extension OperationPickerContentViewConfig {
    
    static func prod(
        height: CGFloat
    ) -> Self {
        
        return .init(
            height: height,
            horizontalPadding: 8,
            spacing: 4
        )
    }
}
