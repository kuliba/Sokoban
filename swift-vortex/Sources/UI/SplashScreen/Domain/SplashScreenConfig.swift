//
//  SplashScreenConfig.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI
import SharedConfigs

public struct SplashScreenConfig {

    let strings: Strings
    let textConfig: TextConfig
    let sizes: Sizes
    let paddings: Paddings
    let backgroundImage: Image
    let logoImage: Image
    
    public struct Strings {
        
        let dayTimeText: String
        let userNameText: String
        
        public init(
            dayTimeText: String,
            userNameText: String
        ) {
            
            self.dayTimeText = dayTimeText
            self.userNameText = userNameText
        }
    }
    
    public struct Sizes {

        let iconSize: CGFloat
        
        public init(
            iconSize: CGFloat
        ) {
            
            self.iconSize = iconSize
        }
    }
    
    public struct Paddings {
        
        let imageBottomPadding: CGFloat
        let bottomPadding: CGFloat
        
        public init(
            imageBottomPadding: CGFloat,
            bottomPadding: CGFloat
        ) {
            
            self.imageBottomPadding = imageBottomPadding
            self.bottomPadding = bottomPadding
        }
    }
    
    public init(
        strings: Strings,
        textConfig: TextConfig,
        sizes: Sizes,
        paddings: Paddings,
        backgroundImage: Image,
        logoImage: Image
    ) {
        self.strings = strings
        self.textConfig = textConfig
        self.sizes = sizes
        self.paddings = paddings
        self.backgroundImage = backgroundImage
        self.logoImage = logoImage
    }
}
