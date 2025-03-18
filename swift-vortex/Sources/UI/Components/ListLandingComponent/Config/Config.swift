//
//  Config.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation
import SwiftUI
import SharedConfigs

public struct Config {
    
    public let background: Color
    public let item: TitleWithSubtitle
    public let title: TextConfig
    public let paddings: Paddings
    public let spacing: CGFloat
    
    public init(
        background: Color,
        item: TitleWithSubtitle,
        title: TextConfig,
        paddings: Paddings,
        spacing: CGFloat
    ) {
        self.background = background
        self.item = item
        self.title = title
        self.paddings = paddings
        self.spacing = spacing
    }
    
    public struct Paddings {
        
        public let horizontal: CGFloat
        public let vertical: CGFloat
        
        public init(horizontal: CGFloat, vertical: CGFloat) {
            self.horizontal = horizontal
            self.vertical = vertical
        }
    }
    
    public struct TitleWithSubtitle {
        
        public let title: TextConfig
        public let subtitle: TextConfig
        
        public init(
            title: TextConfig,
            subtitle: TextConfig
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
