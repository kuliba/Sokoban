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
            paddings: .init(top: 134, bottom: 60),
            spacing: 28,
            scaleEffect: .init(start: 1, end: 1.05)
        )
    }
}

extension SplashScreenDynamicConfig {
    
    static func prod() -> Self {
        
        return .init(
            greeting: .init(
                textFont: .textH1R24322(),
                textColor: .black
            ),
            footer: .init(
                textFont: .textBodyMR14180(),
                textColor: .white
            )
        )
    }
}
