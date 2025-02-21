//
//  Config.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation
import SwiftUI
import SharedConfigs

struct Config {
    
    let background: Color
    let item: TitleWithSubtitle
    let title: TextConfig
    let spacing: CGFloat
    
    public init(
        background: Color,
        item: TitleWithSubtitle,
        title: TextConfig,
        spacing: CGFloat
    ) {
        self.background = background
        self.item = item
        self.title = title
        self.spacing = spacing
    }
    
    public struct TitleWithSubtitle {
        let title: TextConfig
        let subtitle: TextConfig
        
        public init(
            title: TextConfig,
            subtitle: TextConfig
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
