//
//  SavingsAccountConfig.swift
//
//
//  Created by Andryusina Nataly on 20.11.2024.
//

import SwiftUI
import SharedConfigs

public struct SavingsAccountConfig {
    
    let chevronDownImage: Image
    let cornerRadius: CGFloat
    let divider: Color
    let icon: Icon
    let list: List
    let navTitle: TitleWithSubtitle
    let offsetForDisplayHeader: CGFloat
    let paddings: Paddings
    let spacing: CGFloat
    
    public init(chevronDownImage: Image, cornerRadius: CGFloat, divider: Color, icon: Icon, list: List, navTitle: TitleWithSubtitle, offsetForDisplayHeader: CGFloat, paddings: Paddings, spacing: CGFloat) {
        self.chevronDownImage = chevronDownImage
        self.cornerRadius = cornerRadius
        self.divider = divider
        self.icon = icon
        self.list = list
        self.navTitle = navTitle
        self.offsetForDisplayHeader = offsetForDisplayHeader
        self.paddings = paddings
        self.spacing = spacing
    }
        
    public struct Icon {
        let leading: CGFloat
        let widthAndHeight: CGFloat
        
        public init(leading: CGFloat, widthAndHeight: CGFloat) {
            self.leading = leading
            self.widthAndHeight = widthAndHeight
        }
    }
    
    public struct Paddings {
        let negativeBottomPadding: CGFloat
        let vertical: CGFloat
        let list: List
        
        public init(negativeBottomPadding: CGFloat, vertical: CGFloat, list: List) {
            self.negativeBottomPadding = negativeBottomPadding
            self.vertical = vertical
            self.list = list
        }
        
        public struct List {
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }
    }
    
    public struct TitleWithSubtitle {
        let title: TextConfig
        let subtitle: TextConfig
        
        public init(title: TextConfig, subtitle: TextConfig) {
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    public struct List {
        
        let background: Color
        let item: TitleWithSubtitle
        let title: TextConfig
        
        public init(background: Color, item: TitleWithSubtitle, title: TextConfig) {
            self.background = background
            self.item = item
            self.title = title
        }
    }
}
