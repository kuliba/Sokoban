//
//  GetCollateralLandingConfig.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI
import DropDownTextListComponent

struct GetCollateralLandingConfig {
    
    let fonts: Fonts
    let backgroundImageHeight: CGFloat
    let paddings: Paddings
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let header: Header
    let conditions: Conditions
    let calculator: Calculator
    let faq: DropDownTextListConfig
    let documents: Documents
    let footer: Footer
    let bottomSheet: BottomSheet
        
    struct Fonts {
        
        let body: FontConfig
        
        init(body: FontConfig) {
            self.body = body
        }
    }
    
    struct Paddings {
        
        let outerLeading: CGFloat
        let outerTrailing: CGFloat
        let outerBottom: CGFloat
        let outerTop: CGFloat
        
        init(
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
        
    struct FontConfig {
        
        let font: Font
        let foreground: Color
        let background: Color
        
        init(
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

extension GetCollateralLandingConfig {

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
        faq: .default,
        documents: .default,
        footer: .default,
        bottomSheet: .default
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
