//
//  CollateralLoanLandingGetCollateralLandingViewConfig.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI
import DropDownTextListComponent

public struct CollateralLoanLandingGetCollateralLandingViewConfig {
    
    public let fonts: Fonts
    public let backgroundImageHeight: CGFloat
    public let paddings: Paddings
    public let spacing: CGFloat
    public let cornerRadius: CGFloat
    
    public let header: Header
    public let conditions: Conditions
    public let calculator: Calculator
    public let frequentlyAskedQuestions: DropDownTextListConfig
    public let documents: Documents
    public let footer: Footer
        
    public init(
        fonts: Fonts,
        backgroundImageHeight: CGFloat,
        paddings: Paddings,
        spacing: CGFloat,
        cornerRadius: CGFloat,
        header: Header,
        conditions: Conditions,
        calculator: Calculator,
        frequentlyAskedQuestions: DropDownTextListConfig,
        documents: Documents,
        footer: Footer
    ) {
        self.fonts = fonts
        self.backgroundImageHeight = backgroundImageHeight
        self.paddings = paddings
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.header = header
        self.conditions = conditions
        self.calculator = calculator
        self.frequentlyAskedQuestions = frequentlyAskedQuestions
        self.documents = documents
        self.footer = footer
    }
    
    public struct Fonts {
        
        public let body: FontConfig
        
        public init(body: FontConfig) {
            self.body = body
        }
    }
    
    public struct Paddings {
        
        let outerLeading: CGFloat
        let outerTrailing: CGFloat
        let outerBottom: CGFloat
        let outerTop: CGFloat
        
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

extension CollateralLoanLandingGetCollateralLandingViewConfig {

    static let `default` = Self(
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
        header: .default,
        conditions: .default,
        calculator: .default,
        frequentlyAskedQuestions: .default,
        documents: .init(),
        footer: .init()
    )
}

extension Color {
    
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let red: Self = .init(red: 1, green: 0.21, blue: 0.21)
    static let iconBackground: Self = .init(red: 0.5, green: 0.8, blue: 0.76)
    static let textPlaceholder: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let buttonPrimaryDisabled: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
    static let divider: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let bottomPanelBackground: Self = .init(red: 0.16, green: 0.16, blue: 0.16)
}
