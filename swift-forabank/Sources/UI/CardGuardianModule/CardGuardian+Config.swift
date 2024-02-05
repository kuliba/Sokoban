//
//  CardGuardian+Config.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import Foundation
import SwiftUI

public extension CardGuardian {
    
    struct Config {
        
        let images: Images 
        let paddings: Paddings
        let sizes: Sizes
        let colors: Colors
        let fonts: Fonts
        
        public init(
            images: Images,
            paddings: Paddings,
            sizes: Sizes,
            colors: Colors,
            fonts: Fonts
        ) {
            self.images = images
            self.paddings = paddings
            self.sizes = sizes
            self.colors = colors
            self.fonts = fonts
        }
    }
}

public extension CardGuardian.Config {
    
    struct Images {
        
        let toggleLock: Image
        let changePin: Image
        let showOnMain: Image
        
        public init(toggleLock: Image, changePin: Image, showOnMain: Image) {
            self.toggleLock = toggleLock
            self.changePin = changePin
            self.showOnMain = showOnMain
        }
        
        func imageByType(
            _ type: IconType
        ) -> Image {
            
            switch type {
            case .toggleLock:
                return toggleLock
            case .changePin:
                return changePin
            case .showOnMain:
                return showOnMain
            }
        }
    }
}

public extension CardGuardian.Config {
    
    enum IconType: Equatable {
        
        case toggleLock
        case changePin
        case showOnMain
    }
}

public extension CardGuardian.Config {
    
    struct Sizes {
        
        let buttonHeight: CGFloat
        let icon: CGFloat
        
        public init(buttonHeight: CGFloat, icon: CGFloat) {
            self.buttonHeight = buttonHeight
            self.icon = icon
        }
        
        var cornerRadius:CGFloat { buttonHeight * 2 }
    }
}

public extension CardGuardian.Config {
    
    struct Paddings {
        
        let leading: CGFloat
        let trailing: CGFloat
        let vertical: CGFloat
        let subtitleLeading: CGFloat

        public init(
            leading: CGFloat,
            trailing: CGFloat,
            vertical: CGFloat,
            subtitleLeading: CGFloat
        ) {
            self.leading = leading
            self.trailing = trailing
            self.vertical = vertical
            self.subtitleLeading = subtitleLeading
        }
    }
}

public extension CardGuardian.Config {
    
    struct Colors {
        let foreground: Color
        let subtitle: Color
        
        public init(foreground: Color, subtitle: Color) {
            self.foreground = foreground
            self.subtitle = subtitle
        }
    }
}

public extension CardGuardian.Config {
    
    struct Fonts {
        let title: Font
        let subtitle: Font
        
        public init(title: Font, subtitle: Font) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
