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
            scaleEffect: .init(start: 1.05, end: 1)
        )
    }
}

extension SplashScreenDynamicConfig {
    
    static func prod() -> Self {
        
        return .init(
            greeting: .init(
                textFont: .textH1Sb24322(),
                textColor: .white
            ),
            message: .init(
                textFont: .textH4R16240(),
                textColor: .white
            ),
            footer: .init(
                textFont: .textH1Sb24322(),
                textColor: .white
            )
        )
    }
}

extension SplashScreenState {
    
    static let initialSplashData: SplashScreenState = .init(
        data: .init(state: .noSplash,
                    background: Image("splashPlaceholder"),
                    logo: Image("vortexLogoNewYear"),
                    footer: "Vortex",
                    greeting: "Good Morning!",
                    message: "С наступающим Вас Новым годом! Это время ожидания чудес, и пусть оно будет наполнено теплом и любовью близких! Здоровья,  мира,  добра, счастья и финансового благополучия Вам и Вашим близких!",
                    animation: .easeOut),
        config: .prod()
    )
}
