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

    public struct Header {
        
        public let height: CGFloat
        public let labelTag: LabelTag
        public let params: Params
        
        public init(
            height: CGFloat,
            labelTag: LabelTag,
            params: Params
        ) {
            self.height = height
            self.labelTag = labelTag
            self.params = params
        }
        
        public struct LabelTag {

            public let fontConfig: FontConfig
            public let cornerSize: CGFloat
            public let topOuterPadding: CGFloat
            public let leadingOuterPadding: CGFloat
            public let horizontalInnerPadding: CGFloat
            public let verticalInnerPadding: CGFloat
            public let rotationDegrees: CGFloat
            
            public init(
                fontConfig: FontConfig,
                cornerSize: CGFloat,
                topOuterPadding: CGFloat,
                leadingOuterPadding: CGFloat,
                horizontalInnerPadding: CGFloat,
                verticalInnerPadding: CGFloat,
                rotationDegrees: CGFloat
            ) {
                self.fontConfig = fontConfig
                self.cornerSize = cornerSize
                self.topOuterPadding = topOuterPadding
                self.leadingOuterPadding = leadingOuterPadding
                self.horizontalInnerPadding = horizontalInnerPadding
                self.verticalInnerPadding = verticalInnerPadding
                self.rotationDegrees = rotationDegrees
            }
        }
        
        public struct Params {
            
            public let fontConfig: FontConfig
            public let spacing: CGFloat
            public let leadingPadding: CGFloat
            public let topPadding: CGFloat
            
            public init(
                fontConfig: FontConfig,
                spacing: CGFloat,
                leadingPadding: CGFloat,
                topPadding: CGFloat
            ) {
                self.fontConfig = fontConfig
                self.spacing = spacing
                self.leadingPadding = leadingPadding
                self.topPadding = topPadding
            }
        }
    }

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

    public struct Calculator {
        
        public let contentLeadingPadding: CGFloat
        public let contentTrailingPadding: CGFloat
        public let backgroundColor: Color
        public let headerText: String
        public let headerFont: FontConfig
        public let headerTopPadding: CGFloat
        public let headerBottomPadding: CGFloat
        public let salaryText: String
        public let salaryFont: FontConfig
        public let salaryLeadingPadding: CGFloat
        public let salaryTrailingPadding: CGFloat
        public let salaryBottomPadding: CGFloat
        public let toggleTrailingPadding: CGFloat
        public let toggleColor: Color
        public let dividerColor: Color
        public let middleSectionSpacing: CGFloat
        public let titleFont: FontConfig
        public let valueFont: FontConfig
        public let periodTitleText: String
        public let percentTitleText: String
        public let depositTitleText: String
        public let desiredAmountTitleText: String
        public let desiredAmountMaxText: String
        public let monthlyPaymentTitleText: String
        public let infoTitleText: String
        public let infoTitleTopPadding: CGFloat
        public let infoTitleBottomPadding: CGFloat
        public let monthlyPaymentTitleTopPadding: CGFloat
        public let monthlyPaymentValueTopPadding: CGFloat
        public let depositTitleTopPadding: CGFloat
        public let desiredAmountTitleTopPadding: CGFloat
        public let spacingBetweenTitleAndValue: CGFloat
        public let chevronColor: Color
        public let chevronSpacing: CGFloat
        public let sliderBottomPadding: CGFloat
        public let bottomPanelCornerRadius: CGFloat
        public let bottomPanelBackgroundColor: Color

        public init(
            contentLeadingPadding: CGFloat,
            contentTrailingPadding: CGFloat,
            backgroundColor: Color,
            headerText: String,
            headerFont: FontConfig,
            headerTopPadding: CGFloat,
            headerBottomPadding: CGFloat,
            salaryText: String,
            salaryFont: FontConfig,
            salaryLeadingPadding: CGFloat,
            salaryTrailingPadding: CGFloat,
            salaryBottomPadding: CGFloat,
            toggleTrailingPadding: CGFloat,
            toggleColor: Color,
            dividerColor: Color,
            middleSectionSpacing: CGFloat,
            titleFont: FontConfig,
            valueFont: FontConfig,
            periodTitleText: String,
            percentTitleText: String,
            depositTitleText: String,
            monthlyPaymentTitleText: String,
            infoTitleText: String,
            infoTitleTopPadding: CGFloat,
            infoTitleBottomPadding: CGFloat,
            monthlyPaymentTitleTopPadding: CGFloat,
            monthlyPaymentValueTopPadding: CGFloat,
            depositTitleTopPadding: CGFloat,
            desiredAmountTitleText: String,
            desiredAmountMaxText: String,
            desiredAmountTitleTopPadding: CGFloat,
            spacingBetweenTitleAndValue: CGFloat,
            chevronColor: Color,
            chevronSpacing: CGFloat,
            sliderBottomPadding: CGFloat,
            bottomPanelCornerRadius: CGFloat,
            bottomPanelBackgroundColor: Color

        ) {
            self.contentLeadingPadding = contentLeadingPadding
            self.contentTrailingPadding = contentTrailingPadding
            self.backgroundColor = backgroundColor
            self.headerText = headerText
            self.headerFont = headerFont
            self.headerTopPadding = headerTopPadding
            self.headerBottomPadding = headerBottomPadding
            self.salaryText = salaryText
            self.salaryFont = salaryFont
            self.salaryLeadingPadding = salaryLeadingPadding
            self.salaryTrailingPadding = salaryTrailingPadding
            self.salaryBottomPadding = salaryBottomPadding
            self.toggleTrailingPadding = toggleTrailingPadding
            self.toggleColor = toggleColor
            self.dividerColor = dividerColor
            self.middleSectionSpacing = middleSectionSpacing
            self.titleFont = titleFont
            self.valueFont = valueFont
            self.periodTitleText = periodTitleText
            self.percentTitleText = percentTitleText
            self.depositTitleText = depositTitleText
            self.monthlyPaymentTitleText = monthlyPaymentTitleText
            self.infoTitleText = infoTitleText
            self.infoTitleTopPadding = infoTitleTopPadding
            self.infoTitleBottomPadding = infoTitleBottomPadding
            self.monthlyPaymentTitleTopPadding = monthlyPaymentTitleTopPadding
            self.monthlyPaymentValueTopPadding = monthlyPaymentValueTopPadding
            self.depositTitleTopPadding = depositTitleTopPadding
            self.desiredAmountTitleText = desiredAmountTitleText
            self.desiredAmountMaxText = desiredAmountMaxText
            self.desiredAmountTitleTopPadding = desiredAmountTitleTopPadding
            self.spacingBetweenTitleAndValue = spacingBetweenTitleAndValue
            self.chevronColor = chevronColor
            self.chevronSpacing = chevronSpacing
            self.sliderBottomPadding = sliderBottomPadding
            self.bottomPanelCornerRadius = bottomPanelCornerRadius
            self.bottomPanelBackgroundColor = bottomPanelBackgroundColor
        }
    }
    
    public struct FrequentlyAskedQuestion {}

    public struct Documents {}

    public struct Footer {}
    
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
            headerText: "Рассчитать кредит",
            headerFont: .init(Font.system(size: 24).bold(), foreground: .white),
            headerTopPadding: 16,
            headerBottomPadding: 12,
            salaryText: "Я получаю зарплату на счет в Фора-Банке",
            salaryFont: .init(Font.system(size: 14), foreground: .white),
            salaryLeadingPadding: 16,
            salaryTrailingPadding: 17,
            salaryBottomPadding: 18,
            toggleTrailingPadding: 22,
            toggleColor: .buttonPrimaryDisabled,
            dividerColor: .divider,
            middleSectionSpacing: 11,
            titleFont: .init(Font.system(size: 12), foreground: .textPlaceholder),
            valueFont: .init(Font.system(size: 20), foreground: .white),
            periodTitleText: "Срок кредита",
            percentTitleText: "Процентная ставка",
            depositTitleText: "Залог",
            monthlyPaymentTitleText: "Ежемесячный платеж",
            infoTitleText: "Представленные параметры являются расчетными и носят справочный характер",
            infoTitleTopPadding: 15,
            infoTitleBottomPadding: 15,
            monthlyPaymentTitleTopPadding: 16,
            monthlyPaymentValueTopPadding: 8,
            depositTitleTopPadding: 24,
            desiredAmountTitleText: "Желаемая сумма кредита",
            desiredAmountMaxText: "До 15 млн. ₽",
            desiredAmountTitleTopPadding: 20,
            spacingBetweenTitleAndValue: 8,
            chevronColor: .divider,
            chevronSpacing: 4,
            sliderBottomPadding: 12,
            bottomPanelCornerRadius: 12,
            bottomPanelBackgroundColor: .bottomPanelBackground
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
