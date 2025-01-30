//
//  CollateralLoanLandingGetShowcaseConfig.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

import SwiftUI
import UIPrimitives

public struct CollateralLoanLandingGetShowcaseViewConfig {
    
    public let fonts: Fonts
    public let paddings: Paddings
    public let headerView: HeaderView
    public let termsView: TermsView
    public let bulletsView: BulletsView
    public let imageView: ImageView
    public let footerView: FooterView
    
    public init(
        fonts: Fonts,
        paddings: Paddings,
        headerView: HeaderView,
        termsView: TermsView,
        bulletsView: BulletsView,
        imageView: ImageView,
        footerView: FooterView
    ) {
        self.fonts = fonts
        self.paddings = paddings
        self.headerView = headerView
        self.termsView = termsView
        self.bulletsView = bulletsView
        self.imageView = imageView
        self.footerView = footerView
    }
    
    public struct Fonts {
        
        public let header: Font
        public let body: Font
        
        public init(header: Font, body: Font) {
         
            self.header = header
            self.body = body
        }
    }
    
    public struct Paddings {

        public let outer: Outer
        public let top: CGFloat

        public init(outer: Outer, top: CGFloat) {
         
            self.outer = outer
            self.top = top
        }
        
        public struct Outer {
            
            public let vertical: CGFloat
            public let leading: CGFloat
            public let trailing: CGFloat
            
            public init(vertical: CGFloat, leading: CGFloat, trailing: CGFloat) {
               
                self.vertical = vertical
                self.leading = leading
                self.trailing = trailing
            }
        }
    }

    public struct HeaderView {

        public let height: CGFloat
        
        public init(height: CGFloat) {
            
            self.height = height
        }
    }

    public struct TermsView {

        public let height: CGFloat
        
        public init(height: CGFloat) {
            
            self.height = height
        }
    }

    public struct BulletsView {

        public let itemSpacing: CGFloat
        public let height: CGFloat
        
        public init(itemSpacing: CGFloat, height: CGFloat) {
            
            self.itemSpacing = itemSpacing
            self.height = height
        }
    }
    
    public struct ImageView {

        public let height: CGFloat
        public let сornerRadius: CGFloat
        
        public init(height: CGFloat, сornerRadius: CGFloat) {
            
            self.height = height
            self.сornerRadius = сornerRadius
        }
    }

    public struct FooterView {

        public let height: CGFloat
        public let topPadding: CGFloat
        public let spacing: CGFloat
        public let buttonForegroundColor: Color

        public init(height: CGFloat, topPadding: CGFloat, spacing: CGFloat, buttonForegroundColor: Color) {

            self.height = height
            self.topPadding = topPadding
            self.spacing = spacing
            self.buttonForegroundColor = buttonForegroundColor
        }
    }
}

extension CollateralLoanLandingGetShowcaseViewConfig {

    public static let base = Self(

        fonts: .init(
            header: Font.system(size: 32).bold(),
            body: Font.system(size: 14)
        ),
        paddings: .init(
            outer: .init(
                vertical: 32,
                leading: 19,
                trailing: 20
            ),
            top: 24
        ),
        headerView: .init(height: 80),
        termsView: .init(height: 24),
        bulletsView: .init(itemSpacing: 4, height: 84),
        imageView: .init(height: 236, сornerRadius: 12),
        footerView: .init(
            height: 48,
            topPadding: 12,
            spacing: 12,
            buttonForegroundColor: .white
        )
    )
}
