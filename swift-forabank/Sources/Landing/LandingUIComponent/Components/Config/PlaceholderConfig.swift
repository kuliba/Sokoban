//
//  SwiftUIView.swift
//
//
//  Created by Andrew Kurdin on 2023-09-08.
//

import SwiftUI

public struct Placeholder {
    
    public struct Config {
        
        public let width: Width
        public let height: Height
        public let padding: Padding
        public let spacing: Spacing
        public let cornerRadius: CornerRadius
        public let gradientColor: GradientColor
        
        // MARK: - Width
        public struct Width {
            
            let title: CGFloat
            let subtitle: CGFloat
            let bonuses3inRow: CGFloat
            let banner: CGFloat
            
            public init(title: CGFloat, subtitle: CGFloat, banner: CGFloat, bonuses3inRow: CGFloat) {
                self.title = title
                self.subtitle = subtitle
                self.banner = banner
                self.bonuses3inRow = bonuses3inRow
            }
        }
        
        // MARK: - Height
        public struct Height {
            
            let titleAndSubtitle: CGFloat
            let bonuses: CGFloat
            let popularDestinationView: CGFloat
            let maxTransfersPerMonth: CGFloat
            let bannersView: CGFloat
            let listOfCountries: CGFloat
            let advantagesAndSupport: CGFloat
            let faq: CGFloat
            let reference: CGFloat
            
            public init(
                titleAndSubtitle: CGFloat,
                bonuses: CGFloat,
                popularDestinationView: CGFloat,
                maxTransfersPerMonth: CGFloat,
                bannersView: CGFloat,
                listOfCountries: CGFloat,
                advantagesAndSupport: CGFloat,
                faq: CGFloat,
                reference: CGFloat
            ) {
                self.titleAndSubtitle = titleAndSubtitle
                self.bonuses = bonuses
                self.popularDestinationView = popularDestinationView
                self.maxTransfersPerMonth = maxTransfersPerMonth
                self.bannersView = bannersView
                self.listOfCountries = listOfCountries
                self.advantagesAndSupport = advantagesAndSupport
                self.faq = faq
                self.reference = reference
            }
        }
        
        // MARK: - CornerRadius
        public struct CornerRadius {
            let roundedRectangle: CGFloat
            let maxCornerRadius: CGFloat
            
            public init(roundedRectangle: CGFloat, maxCornerRadius: CGFloat) {
                self.roundedRectangle = roundedRectangle
                self.maxCornerRadius = maxCornerRadius
            }
        }
        
        // MARK: - Padding
        public struct Padding {
            let globalBottom: CGFloat
            let titleBottom: CGFloat
            let globalHorizontal: CGFloat
            
            public init(globalHorizontal: CGFloat, globalBottom: CGFloat, titleBottom: CGFloat) {
                self.globalHorizontal = globalHorizontal
                self.globalBottom = globalBottom
                self.titleBottom = titleBottom
            }
        }
        
        // MARK: - Spacing
        public struct Spacing {
            let titleViewSpacing: CGFloat
            let globalVStack: CGFloat
            let bonuses3inRow: CGFloat
            let bannersView: CGFloat
            
            public init(
                titleViewSpacing: CGFloat,
                globalVStack: CGFloat,
                bonuses3inRow: CGFloat,
                bannersView: CGFloat
            ) {
                self.titleViewSpacing = titleViewSpacing
                self.globalVStack = globalVStack
                self.bonuses3inRow = bonuses3inRow
                self.bannersView = bannersView
            }
        }
        
        // MARK: - GradientColor
        public struct GradientColor {
            let fromLeft: Color
            let toRight: Color
            
            public init(fromLeft: Color, toRight: Color) {
                self.fromLeft = fromLeft
                self.toRight = toRight
            }
        }
        
        // MARK: - Init
        public init(
            width: Width,
            height: Height,
            padding: Padding,
            spacing: Spacing,
            cornerRadius: CornerRadius,
            gradientColor: GradientColor
        ) {
            self.width = width
            self.height = height
            self.padding = padding
            self.spacing = spacing
            self.cornerRadius = cornerRadius
            self.gradientColor = gradientColor
        }
    }
}
