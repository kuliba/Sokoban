//
//  Config.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import SwiftUI

public struct Config {
    
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


public extension Config {
    
    struct Images {
        
        let accountDetails: Image
        let accountStatement: Image
        
        public init(
            accountDetails: Image,
            accountStatement: Image
        ) {
            self.accountDetails = accountDetails
            self.accountStatement = accountStatement
        }
        
        func imageByType(
            _ type: IconType
        ) -> Image {
            
            switch type {
            case .accountDetails:
                return accountDetails
            case .accountStatement:
                return accountStatement
            }
        }
    }
}

public extension Config {
    
    enum IconType: Equatable {
        
        case accountDetails
        case accountStatement
    }
}

public extension Config {
    
    struct Sizes {
        
        let buttonHeight: CGFloat
        let icon: CGFloat
        
        public init(
            buttonHeight: CGFloat,
            icon: CGFloat
        ) {
            self.buttonHeight = buttonHeight
            self.icon = icon
        }
        
        var cornerRadius:CGFloat { buttonHeight * 2 }
    }
}

public extension Config {
    
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

public extension Config {
    
    struct Colors {
        let foreground: Color
        let subtitle: Color
        
        public init(foreground: Color, subtitle: Color) {
            self.foreground = foreground
            self.subtitle = subtitle
        }
    }
}

public extension Config {
    
    struct Fonts {
        let title: Font
        let subtitle: Font
        
        public init(
            title: Font,
            subtitle: Font
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
