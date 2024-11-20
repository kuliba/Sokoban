//
//  CollateralLoanLandingGetJsonAbroadViewConfig.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadViewConfig {
    
    public let fonts: Fonts
    public let backgroundImageHeight: CGFloat
    public let paddings: Paddings
    public let spacing: CGFloat
    public let cornerRadius: CGFloat
    public let header: Header
    public let conditions: Conditions
    public let calculator: Calculator
    public let frequentlyAskedQuestion: FrequentlyAskedQuestion
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
        frequentlyAskedQuestion: FrequentlyAskedQuestion,
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
        self.frequentlyAskedQuestion = frequentlyAskedQuestion
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
        
        public init(
            outerLeading: CGFloat,
            outerTrailing: CGFloat,
            outerBottom: CGFloat
        ) {
            self.outerLeading = outerLeading
            self.outerTrailing = outerTrailing
            self.outerBottom = outerBottom
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

extension CollateralLoanLandingGetJsonAbroadViewConfig {

    static let `default` = Self(
        fonts: .init(body: FontConfig(Font.system(size: 14))),
        backgroundImageHeight: 703,
        paddings: .init(
            outerLeading: 16,
            outerTrailing: 15,
            outerBottom: 20
        ),
        spacing: 16,
        cornerRadius: 12,
        header: .init(
            height: 642,
            labelTag: .init(
                fontConfig: .init(
                    Font.system(size: 32).bold(),
                    foreground: .white,
                    background: .red
                ),
                cornerSize: 10,
                topOuterPadding: 215,
                leadingOuterPadding: 25,
                horizontalInnerPadding: 10,
                verticalInnerPadding: 6,
                rotationDegrees: -5
            ),
            params: .init(
                fontConfig: .init(Font.system(size: 14)),
                spacing: 20,
                leadingPadding: 20,
                topPadding: 30
            )
        ),
        conditions: .init(
            header: .init(
                text: "Выгодные условия",
                headerFont: .init(Font.system(size: 24).bold())
            ),
            backgroundColor: Color.grayLightest,
            spacing: 13,
            horizontalPadding: 16,
            listTopPadding: 12,
            iconSize: CGSize(width: 40, height: 40),
            iconBackground: .iconBackground,
            iconTrailingPadding: 16,
            titleFont: .init(
                Font.system(size: 14),
                foreground: .textPlaceholder
            ),
            subTitleFont: .init(Font.system(size: 16)),
            subTitleTopPadding: 2
        ),
        calculator: .init(
            contentLeadingPadding: 16,
            contentTrailingPadding: 22,
            backgroundColor: .black,
            dividerColor: .divider,
            middleSectionSpacing: 11,
            titleFont: .init(Font.system(size: 12), foreground: .textPlaceholder),
            valueFont: .init(Font.system(size: 20), foreground: .white),
            spacingBetweenTitleAndValue: 8,
            chevronColor: .divider,
            chevronSpacing: 4,
            bottomPanelCornerRadius: 12,
            bottomPanelBackgroundColor: .bottomPanelBackground,
            header: .init(
                text: "Рассчитать кредит",
                font: .init(Font.system(size: 24).bold(), foreground: .white),
                topPadding: 16,
                bottomPadding: 12
            ),
            salary: .init(
                text: "Я получаю зарплату на счет в Фора-Банке",
                font: .init(Font.system(size: 14), foreground: .white),
                leadingPadding: 16,
                trailingPadding: 17,
                bottomPadding: 18,
                toggleTrailingPadding: 22,
                toggleColor: .buttonPrimaryDisabled
            ),
            period: .init(titleText: "Срок кредита"),
            percent: .init(titleText: "Процентная ставка"),
            desiredAmount: .init(
                titleText: "Желаемая сумма кредита",
                maxText: "До 15 млн. ₽",
                titleTopPadding: 20,
                sliderBottomPadding: 12
            ),
            monthlyPayment: .init(
                titleText: "Ежемесячный платеж",
                titleTopPadding: 16,
                valueTopPadding: 8
            ),
            info: .init(
                titleText: "Представленные параметры являются расчетными и носят справочный характер",
                titleTopPadding: 15,
                titleBottomPadding: 15
            ),
            deposit: .init(
                titleText: "Залог",
                titleTopPadding: 24
            )
        ),
        frequentlyAskedQuestion: .init(),
        documents: .init(),
        footer: .init()
    )
}

private extension Color {
    
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let red: Self = .init(red: 1, green: 0.21, blue: 0.21)
    static let iconBackground: Self = .init(red: 0.5, green: 0.8, blue: 0.76)
    static let textPlaceholder: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let buttonPrimaryDisabled: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
    static let divider: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let bottomPanelBackground: Self = .init(red: 0.16, green: 0.16, blue: 0.16)
}
