//
//  IconWithTwoTextLinesConfig.swift
//  
//
//  Created by Andrew Kurdin on 2023-09-14.
//

import SwiftUI

public extension UILanding.IconWithTwoTextLines {
    
    struct Config {
        
        let icon: Icon
        let horizontalPadding: CGFloat
        let title: TextConfig
        let subTitle: TextConfig
        
        public struct Icon {
            let size: CGFloat
            let paddingBottom: CGFloat
            
            public init(size: CGFloat, paddingBottom: CGFloat) {
                self.size = size
                self.paddingBottom = paddingBottom
            }
        }
        public struct TextConfig {
            let font: Font
            let color: Color
            let paddingBottom: CGFloat
            
            public init(font: Font, color: Color, paddingBottom: CGFloat) {
                self.font = font
                self.color = color
                self.paddingBottom = paddingBottom
            }
        }
        
        public init(icon: Icon, horizontalPadding: CGFloat, title: TextConfig, subTitle: TextConfig) {
            self.icon = icon
            self.horizontalPadding = horizontalPadding
            self.title = title
            self.subTitle = subTitle
        }
    }
}
