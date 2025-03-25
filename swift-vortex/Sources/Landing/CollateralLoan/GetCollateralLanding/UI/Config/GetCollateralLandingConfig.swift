//
//  GetCollateralLandingConfig.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI
import DropDownTextListComponent

public struct GetCollateralLandingConfig {
    
    public let fonts: Fonts
    public let backgroundImageHeight: CGFloat
    public let paddings: Paddings
    public let spacing: CGFloat
    public let cornerRadius: CGFloat
    public let header: Header
    public let conditions: Conditions
    public let calculator: Calculator
    public let faq: DropDownTextListConfig
    public let documents: Documents
    public let footer: Footer
    public let bottomSheet: BottomSheet
        
    public init(
        fonts: Fonts,
        backgroundImageHeight: CGFloat,
        paddings: Paddings,
        spacing: CGFloat,
        cornerRadius: CGFloat,
        header: Header,
        conditions: Conditions,
        calculator: Calculator,
        faq: DropDownTextListConfig,
        documents: Documents,
        footer: Footer,
        bottomSheet: BottomSheet
    ) {
        self.fonts = fonts
        self.backgroundImageHeight = backgroundImageHeight
        self.paddings = paddings
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.header = header
        self.conditions = conditions
        self.calculator = calculator
        self.faq = faq
        self.documents = documents
        self.footer = footer
        self.bottomSheet = bottomSheet
    }
    
    public struct Fonts {
        
        public let body: FontConfig
        
        public init(
            body: FontConfig
        ) {
            self.body = body
        }
    }
    
    public struct Paddings {
        
        public let outerLeading: CGFloat
        public let outerTrailing: CGFloat
        public let outerBottom: CGFloat
        public let outerTop: CGFloat
        
        public init(
            outerLeading: CGFloat,
            outerTrailing: CGFloat,
            outerBottom: CGFloat,
            outerTop: CGFloat
        ) {
            self.outerLeading = outerLeading
            self.outerTrailing = outerTrailing
            self.outerBottom = outerBottom
            self.outerTop = outerTop
        }
    }
        
    public struct FontConfig {
        
        public let font: Font
        public let foreground: Color
        public let background: Color
        
        public init(
            _ font: Font,
            foreground: Color = .black,
            background: Color = .white
        ) {
            self.font = font
            self.foreground = foreground
            self.background = background
        }
    }
}

public extension GetCollateralLandingConfig {

    static let preview = Self(
        fonts: .init(body: FontConfig(Font.system(size: 14))),
        backgroundImageHeight: 703,
        paddings: .init(
            outerLeading: 16,
            outerTrailing: 15,
            outerBottom: 20,
            outerTop: 16
        ),
        spacing: 16,
        cornerRadius: 12,
        header: .preview,
        conditions: .preview,
        calculator: .preview,
        faq: .preview,
        documents: .preview,
        footer: .preview,
        bottomSheet: .preview
    )
}

extension Color {
    
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let unselected: Self = .init(red: 0.92, green: 0.92, blue: 0.92)
    static let red: Self = .init(red: 1, green: 0.21, blue: 0.21)
    static let iconBackground: Self = .init(red: 0.5, green: 0.8, blue: 0.76)
    static let textPlaceholder: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let buttonPrimaryDisabled: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
    static let divider: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let bottomPanelBackground: Self = .init(red: 0.16, green: 0.16, blue: 0.16)
    static let faqDivider: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
}
