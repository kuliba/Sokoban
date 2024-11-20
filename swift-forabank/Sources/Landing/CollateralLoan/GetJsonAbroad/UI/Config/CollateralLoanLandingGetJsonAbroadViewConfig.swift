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
        public let dividerColor: Color
        public let middleSectionSpacing: CGFloat
        public let titleFont: FontConfig
        public let valueFont: FontConfig
        public let spacingBetweenTitleAndValue: CGFloat
        public let chevronColor: Color
        public let chevronSpacing: CGFloat
        public let bottomPanelCornerRadius: CGFloat
        public let bottomPanelBackgroundColor: Color

        public let header: Header
        public let salary: Salary
        public let period: Period
        public let percent: Percent
        public let desiredAmount: DesiredAmount
        public let monthlyPayment: MonthlyPayment
        public let info: Info
        public let deposit: Deposit

        public init(
            contentLeadingPadding: CGFloat,
            contentTrailingPadding: CGFloat,
            backgroundColor: Color,
            dividerColor: Color,
            middleSectionSpacing: CGFloat,
            titleFont: FontConfig,
            valueFont: FontConfig,
            spacingBetweenTitleAndValue: CGFloat,
            chevronColor: Color,
            chevronSpacing: CGFloat,
            bottomPanelCornerRadius: CGFloat,
            bottomPanelBackgroundColor: Color,
            header: Header,
            salary: Salary,
            period: Period,
            percent: Percent,
            desiredAmount: DesiredAmount,
            monthlyPayment: MonthlyPayment,
            info: Info,
            deposit: Deposit
        ) {
            self.contentLeadingPadding = contentLeadingPadding
            self.contentTrailingPadding = contentTrailingPadding
            self.backgroundColor = backgroundColor
            self.dividerColor = dividerColor
            self.middleSectionSpacing = middleSectionSpacing
            self.titleFont = titleFont
            self.valueFont = valueFont
            self.spacingBetweenTitleAndValue = spacingBetweenTitleAndValue
            self.chevronColor = chevronColor
            self.chevronSpacing = chevronSpacing
            self.bottomPanelCornerRadius = bottomPanelCornerRadius
            self.bottomPanelBackgroundColor = bottomPanelBackgroundColor
            self.header = header
            self.salary = salary
            self.period = period
            self.percent = percent
            self.desiredAmount = desiredAmount
            self.monthlyPayment = monthlyPayment
            self.info = info
            self.deposit = deposit
        }
        
        public struct Header {

            public let text: String
            public let font: FontConfig
            public let topPadding: CGFloat
            public let bottomPadding: CGFloat
            
            public init(text: String, font: FontConfig, topPadding: CGFloat, bottomPadding: CGFloat) {
                
                self.text = text
                self.font = font
                self.topPadding = topPadding
                self.bottomPadding = bottomPadding
            }
        }
        
        public struct Salary {
            
            public let text: String
            public let font: FontConfig
            public let leadingPadding: CGFloat
            public let trailingPadding: CGFloat
            public let bottomPadding: CGFloat
            public let toggleTrailingPadding: CGFloat
            public let toggleColor: Color
            
            public init(
                text: String,
                font: FontConfig,
                leadingPadding: CGFloat,
                trailingPadding: CGFloat,
                bottomPadding: CGFloat,
                toggleTrailingPadding: CGFloat,
                toggleColor: Color
            ) {
                self.text = text
                self.font = font
                self.leadingPadding = leadingPadding
                self.trailingPadding = trailingPadding
                self.bottomPadding = bottomPadding
                self.toggleTrailingPadding = toggleTrailingPadding
                self.toggleColor = toggleColor
            }
        }
        
        public struct Period {
            
            public let titleText: String
            
            public init(titleText: String) {
                
                self.titleText = titleText
            }
        }
        
        public struct Percent {
            
            public let titleText: String

            public init(titleText: String) {
                
                self.titleText = titleText
            }
        }
        
        public struct Deposit {
            
            public let titleText: String
            public let titleTopPadding: CGFloat

            public init(titleText: String, titleTopPadding: CGFloat) {
                self.titleText = titleText
                self.titleTopPadding = titleTopPadding
            }
        }
        
        public struct DesiredAmount {
            
            public let titleText: String
            public let maxText: String
            public let titleTopPadding: CGFloat
            public let sliderBottomPadding: CGFloat

            public init(
                titleText: String,
                maxText: String,
                titleTopPadding: CGFloat,
                sliderBottomPadding: CGFloat
            ) {
                self.titleText = titleText
                self.maxText = maxText
                self.titleTopPadding = titleTopPadding
                self.sliderBottomPadding = sliderBottomPadding
            }
        }
        
        public struct MonthlyPayment {
            
            public let titleText: String
            public let titleTopPadding: CGFloat
            public let valueTopPadding: CGFloat
            
            public init(titleText: String, titleTopPadding: CGFloat, valueTopPadding: CGFloat) {
                
                self.titleText = titleText
                self.titleTopPadding = titleTopPadding
                self.valueTopPadding = valueTopPadding
            }
        }
        
        public struct Info {
            
            public let infoTitleText: String
            public let infoTitleTopPadding: CGFloat
            public let infoTitleBottomPadding: CGFloat
            
            public init(
                infoTitleText: String,
                infoTitleTopPadding: CGFloat,
                infoTitleBottomPadding: CGFloat
            ) {
                self.infoTitleText = infoTitleText
                self.infoTitleTopPadding = infoTitleTopPadding
                self.infoTitleBottomPadding = infoTitleBottomPadding
            }
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
                infoTitleText: "Представленные параметры являются расчетными и носят справочный характер",
                infoTitleTopPadding: 15,
                infoTitleBottomPadding: 15
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
