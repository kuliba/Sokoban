//
//  IconWithTwoTextLinesConfig.swift
//  
//
//  Created by Andrew Kurdin on 2023-09-14.
//

import SwiftUI

public extension UILanding.IconWithTwoTextLines {
    
    struct Config {
        
        let paddings: Paddings
        let icon: Icon
        let title: TextConfig
        let subTitle: TextConfig
        
        public struct Paddings {
            
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }
        
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
        
        public init(paddings: Paddings, icon: Icon, title: TextConfig, subTitle: TextConfig) {
            self.paddings = paddings
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
        }
    }
}
