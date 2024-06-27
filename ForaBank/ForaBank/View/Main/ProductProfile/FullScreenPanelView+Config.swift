//
//  FullScreenPanelView+Config.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI

extension FullScreenPanelView {
    
    struct Config {
        
        let colors: Colors
        let height: CGFloat
        let paddings: Paddings
        let spacings: Spacings
        let fonts: Fonts
    }
    
    struct Paddings {
        
        let leading: CGFloat
        let trailing: CGFloat
        let subtitleLeading: CGFloat
    }
    
    struct Fonts {
        
        let title: Font
        let subtitle: Font
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

extension FullScreenPanelView.Config {
    
    static let `default`: Self = .init(
        colors: .init(
            background: .bgIconGrayLightest,
            title: .textSecondary,
            subtitle: .textPlaceholder),
        height: 40,
        paddings: .init(
            leading: 8,
            trailing: 8,
            subtitleLeading: 48),
        spacings: .init(vstack: 24, hstack: 8),
        fonts: .init(title: .textH4M16240(), subtitle: .textBodyMR14200()))
}
