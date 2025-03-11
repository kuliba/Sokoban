//
//  SplashScreenSettings.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.03.2025.
//

import SplashScreenCore
import SwiftUI
import VortexTools

struct SplashScreenSettings<Image> {
    
    let image: Image
    let period: String
}

extension SplashScreenSettings: Equatable where Image: Equatable {}

extension SplashScreenSettings: Categorized {
    
    var category: String { period }
}

// MARK: - ImageSplashScreenSettings

typealias ImageSplashScreenSettings = SplashScreenSettings<SwiftUI.Image>

// MARK: - LinkSplashScreenSettings

typealias LinkSplashScreenSettings = SplashScreenSettings<String>

extension SplashScreenSettings where Image == String {
    
    var link: String { image }
    
    init(
        link: String,
        period: String
    ) {
        self.init(image: link, period: period)
    }
}
