//
//  SplashScreenStaticConfig+prod.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import SplashScreen
import SwiftUI

extension SplashScreenStaticConfig {
    
    static func prod() -> Self {
        
        return .init(
            logoSize: .init(
                width: 64,
                height: 64
            ),
            paddings: .init(top: 32, bottom: 200),
            spacing: 64,
            scaleEffect: .init(start: 1, end: 1.05)
        )
    }
}
