//
//  SavingsAccountConfig.swift
//
//
//  Created by Andryusina Nataly on 20.11.2024.
//

import SwiftUI
import SharedConfigs
import DropDownTextListComponent

public struct SavingsAccountConfig {
    
    let backImage: Image
    let bannerHeight: CGFloat
    let chevronDownImage: Image
    let cornerRadius: CGFloat
    let continueButton: ContinueButton
    let divider: Color
    let icon: Icon
    let list: List
    let navTitle: NavTitleWithSubtitle
    let offsetForDisplayHeader: CGFloat
    let paddings: Paddings
    let spacing: CGFloat
    let questionHeight: CGFloat
    
    public init(backImage: Image, bannerHeight: CGFloat, chevronDownImage: Image, cornerRadius: CGFloat, continueButton: ContinueButton, divider: Color, icon: Icon, list: List, navTitle: NavTitleWithSubtitle, offsetForDisplayHeader: CGFloat, paddings: Paddings, spacing: CGFloat, questionHeight: CGFloat) {
        self.backImage = backImage
        self.bannerHeight = bannerHeight
        self.chevronDownImage = chevronDownImage
        self.cornerRadius = cornerRadius
        self.continueButton = continueButton
        self.divider = divider
        self.icon = icon
        self.list = list
        self.navTitle = navTitle
        self.offsetForDisplayHeader = offsetForDisplayHeader
        self.paddings = paddings
        self.spacing = spacing
        self.questionHeight = questionHeight
    }
       
    public struct ContinueButton {
        let background: Color
        let cornerRadius: CGFloat
        let height: CGFloat
        let label: String
        let title: TextConfig
        
        public init(background: Color, cornerRadius: CGFloat, height: CGFloat, label: String, title: TextConfig) {
            self.background = background
            self.cornerRadius = cornerRadius
            self.height = height
            self.label = label
            self.title = title
        }
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
    
    public struct NavTitleWithSubtitle {
        let title: TitleConfig
        let subtitle: TitleConfig
        
        public init(title: TitleConfig, subtitle: TitleConfig) {
            self.title = title
            self.subtitle = subtitle
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

extension SavingsAccountConfig {
    
    var dropDownTextListConfig: DropDownTextListConfig {
        
        .init(
            cornerRadius: cornerRadius,
            chevronDownImage: chevronDownImage,
            layouts: .init(
                horizontalPadding: paddings.list.horizontal,
                verticalPadding: paddings.list.vertical
            ),
            colors: .init(
                divider: divider,
                background: list.background
            ),
            fonts: .init(
                title: list.title,
                itemTitle: list.item.title,
                itemSubtitle: list.item.subtitle
            )
        )
    }
}
