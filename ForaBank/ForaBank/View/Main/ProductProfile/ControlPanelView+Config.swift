//
//  ControlPanelView+Config.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI

extension ControlPanelView {
    
    struct Config {
        
        let colors: Colors
        let height: CGFloat
        let paddings: Paddings
        let spacings: Spacings
        let fonts: Fonts
    }
    
    struct Paddings {
        
        let horizontal: CGFloat
        let top: CGFloat
    }
    
    struct Fonts {
        
        let title: Font
    }
    
    struct Colors {
        
        let background: Color
        let title: Color
        let subtitle: Color
    }
    
    struct Spacings {
        
        let vstack: CGFloat
        let hstack: CGFloat
    }
}
