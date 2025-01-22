//
//  SplashScreenData.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI

public struct SplashScreenData {
    
    public let backgroundImage: Image?
    public let logoImage: Image?
    public let userNameText: String
    public let dayTimeText: String
    
    public init(
        backgroundImage: Image,
        logoImage: Image,
        userNameText: String,
        dayTimeText: String
    ) {
        self.backgroundImage = backgroundImage
        self.logoImage = logoImage
        self.userNameText = userNameText
        self.dayTimeText = dayTimeText
    }
}
