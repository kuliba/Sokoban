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
    }
}

public extension CardGuardian.Config {
    
    struct Images {
        
        let toggleLock: Image
        let changePin: Image
        let showOnMain: Image
        
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
        
        var cornerRadius:CGFloat { buttonHeight * 2 }
    }
}

public extension CardGuardian.Config {
    
    struct Paddings {
        
        let leading: CGFloat // 20
        let trailing: CGFloat // 80
        let vertical: CGFloat // 8
        let subtitleLeading: CGFloat // 56

        public init(leading: CGFloat, trailing: CGFloat, vertical: CGFloat, subtitleLeading: CGFloat) {
            self.leading = leading
            self.trailing = trailing
            self.vertical = vertical
            self.subtitleLeading = subtitleLeading
        }
    }
}

public extension CardGuardian.Config {
    
    struct Colors {
        let foreground: Color // text/Secondary
        let subtitle: Color // Text/placeholder
    }
}

public extension CardGuardian.Config {
    
    struct Fonts {
        let title: Font // Font.custom("Inter", size: 16).weight(.medium)
        let subtitle: Font // Font.custom("Inter", size: 14)
    }
}
