//
//  CollateralLoanLandingGetJsonAbroadViewConfig+Conditions.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import SwiftUI

extension CollateralLoanLandingGetJsonAbroadViewConfig {
    
    public struct Conditions {
        
        public let header: Header
        public let backgroundColor: Color
        public let spacing: CGFloat
        public let horizontalPadding: CGFloat
        public let listTopPadding: CGFloat
        public let iconSize: CGSize
        public let iconBackground: Color
        public let iconTrailingPadding: CGFloat
        public let titleFont: FontConfig
        public let subTitleFont: FontConfig
        public let subTitleTopPadding: CGFloat

        public init(
            header: Header,
            backgroundColor: Color,
            spacing: CGFloat,
            horizontalPadding: CGFloat,
            listTopPadding: CGFloat,
            iconSize: CGSize,
            iconBackground: Color,
            iconTrailingPadding: CGFloat,
            titleFont: FontConfig,
            subTitleFont: FontConfig,
            subTitleTopPadding: CGFloat
        ) {
            
            self.header = header
            self.backgroundColor = backgroundColor
            self.spacing = spacing
            self.horizontalPadding = horizontalPadding
            self.listTopPadding = listTopPadding
            self.iconSize = iconSize
            self.iconBackground = iconBackground
            self.iconTrailingPadding = iconTrailingPadding
            self.titleFont = titleFont
            self.subTitleFont = subTitleFont
            self.subTitleTopPadding = subTitleTopPadding
        }
        
        public struct Header {
            
            public let text: String
            public let headerFont: FontConfig

            public init(
                text: String,
                headerFont: FontConfig
            ) {
                
                self.text = text
                self.headerFont = headerFont
            }
        }
    }
}
