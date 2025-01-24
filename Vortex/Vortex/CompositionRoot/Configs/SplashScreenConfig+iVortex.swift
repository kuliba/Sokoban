//
//  SplashScreenConfig+iVortex.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 16.01.2025.
//

import SplashScreen
import SwiftUI

extension SplashScreenConfig {
    
    static let iVortex: Self = .init(
        textConfig: .init(textFont: .textH3Sb18240(), textColor: .textSecondary),
        sizes: .init(iconSize: 64),
        paddings: .init(imageBottomPadding: 32, bottomPadding: 200),
        defaultBackgroundImage: Image("splashPlaceholder"),
        defaultLogoImage: Image("vortexLogoNewYear")
    )
}
