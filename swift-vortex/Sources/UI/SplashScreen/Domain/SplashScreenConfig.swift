//
//  SplashScreenConfig.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI
import SharedConfigs

public struct SplashScreenConfig {

    let textConfig: TextConfig
    let sizes: Sizes
    let paddings: Paddings
    let defaultBackgroundImage: Image
    let defaultLogoImage: Image
    
    public struct Strings {
        
        let defaultDayTimeText: String
        let defaultUserNameText: String
        
        public init(
            dayTimeText: String,
            userNameText: String
        ) {
            
            self.defaultDayTimeText = dayTimeText
            self.defaultUserNameText = userNameText
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
        textConfig: TextConfig,
        sizes: Sizes,
        paddings: Paddings,
        defaultBackgroundImage: Image,
        defaultLogoImage: Image
    ) {
        self.textConfig = textConfig
        self.sizes = sizes
        self.paddings = paddings
        self.defaultBackgroundImage = defaultBackgroundImage
        self.defaultLogoImage = defaultLogoImage
    }
}
