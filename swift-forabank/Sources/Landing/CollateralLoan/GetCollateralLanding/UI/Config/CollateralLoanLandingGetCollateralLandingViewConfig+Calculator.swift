//
//  CollateralLoanLandingGetCollateralLandingViewConfig+Calculator.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

extension CollateralLoanLandingGetCollateralLandingViewConfig {
    
    public struct Calculator {
        
        public let root: Root
        public let header: Header
        public let salary: Salary
        public let period: Period
        public let percent: Percent
        public let desiredAmount: DesiredAmount
        public let monthlyPayment: MonthlyPayment
        public let info: Info
        public let deposit: Deposit

        public init(
            root: Root,
            header: Header,
            salary: Salary,
            period: Period,
            percent: Percent,
            desiredAmount: DesiredAmount,
            monthlyPayment: MonthlyPayment,
            info: Info,
            deposit: Deposit
        ) {
            self.root = root
            self.header = header
            self.salary = salary
            self.period = period
            self.percent = percent
            self.desiredAmount = desiredAmount
            self.monthlyPayment = monthlyPayment
            self.info = info
            self.deposit = deposit
        }
        
        public struct Root {
            
            public let layouts: Layouts
            public let fonts: Fonts
            public let colors: Colors

            public init(layouts: Layouts, fonts: Fonts, colors: Colors) {
                self.layouts = layouts
                self.fonts = fonts
                self.colors = colors
            }
            
            public struct Layouts {
                
                public let height: CGFloat
                public let contentLeadingPadding: CGFloat
                public let contentTrailingPadding: CGFloat
                public let middleSectionSpacing: CGFloat
                public let spacingBetweenTitleAndValue: CGFloat
                public let chevronSpacing: CGFloat
                public let bottomPanelCornerRadius: CGFloat
                public let chevronOffsetY: CGFloat
                
                public init(
                    height: CGFloat,
                    contentLeadingPadding: CGFloat,
                    contentTrailingPadding: CGFloat,
                    middleSectionSpacing: CGFloat,
                    spacingBetweenTitleAndValue: CGFloat,
                    chevronSpacing: CGFloat,
                    bottomPanelCornerRadius: CGFloat,
                    chevronOffsetY: CGFloat
                ) {
                    self.height = height
                    self.contentLeadingPadding = contentLeadingPadding
                    self.contentTrailingPadding = contentTrailingPadding
                    self.middleSectionSpacing = middleSectionSpacing
                    self.spacingBetweenTitleAndValue = spacingBetweenTitleAndValue
                    self.chevronSpacing = chevronSpacing
                    self.bottomPanelCornerRadius = bottomPanelCornerRadius
                    self.chevronOffsetY = chevronOffsetY
                }
            }
            
            public struct Fonts {
                
                public let title: FontConfig
                public let value: FontConfig
                
                public init(title: FontConfig, value: FontConfig) {
                    self.title = title
                    self.value = value
                }
            }
            
            public struct Colors {
                
                public let background: Color
                public let divider: Color
                public let chevron: Color
                public let bottomPanelBackground: Color
                
                public init(
                    background: Color,
                    divider: Color,
                    chevron: Color,
                    bottomPanelBackground: Color
                ) {
                    self.background = background
                    self.divider = divider
                    self.chevron = chevron
                    self.bottomPanelBackground = bottomPanelBackground
                }
            }
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
            public let toggle: ToggleConfig
            public let slider: Slider
            
            public init(
                text: String,
                font: FontConfig,
                leadingPadding: CGFloat,
                trailingPadding: CGFloat,
                bottomPadding: CGFloat,
                toggleTrailingPadding: CGFloat,
                toggle: ToggleConfig,
                slider: Slider
            ) {
                self.text = text
                self.font = font
                self.leadingPadding = leadingPadding
                self.trailingPadding = trailingPadding
                self.bottomPadding = bottomPadding
                self.toggleTrailingPadding = toggleTrailingPadding
                self.toggle = toggle
                self.slider = slider
            }
        }
        
        public struct Slider {
            
            public let minTrackColor: Color
            public let maxTrackColor: Color
            public let thumbDiameter: CGFloat
            public let trackHeight: CGFloat
            public let maximumValue: Float
            
            public init(
                minTrackColor: Color,
                maxTrackColor: Color,
                thumbDiameter: CGFloat,
                trackHeight: CGFloat,
                maximumValue: Float
            ) {
                self.minTrackColor = minTrackColor
                self.maxTrackColor = maxTrackColor
                self.thumbDiameter = thumbDiameter
                self.trackHeight = trackHeight
                self.maximumValue = maximumValue
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
            public let fontValue: FontConfig

            public init(
                titleText: String,
                maxText: String,
                titleTopPadding: CGFloat,
                sliderBottomPadding: CGFloat,
                fontValue: FontConfig
            ) {
                self.titleText = titleText
                self.maxText = maxText
                self.titleTopPadding = titleTopPadding
                self.sliderBottomPadding = sliderBottomPadding
                self.fontValue = fontValue
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
            
            public let titleText: String
            public let titleTopPadding: CGFloat
            public let titleBottomPadding: CGFloat
            
            public init(
                titleText: String,
                titleTopPadding: CGFloat,
                titleBottomPadding: CGFloat
            ) {
                self.titleText = titleText
                self.titleTopPadding = titleTopPadding
                self.titleBottomPadding = titleBottomPadding
            }
        }
    }
}

extension CollateralLoanLandingGetCollateralLandingViewConfig.Calculator {
 
    static let `default` = Self(
        root: .init(
            layouts: .init(
                height: 468,
                contentLeadingPadding: 16,
                contentTrailingPadding: 22,
                middleSectionSpacing: 11,
                spacingBetweenTitleAndValue: 8,
                chevronSpacing: 4,
                bottomPanelCornerRadius: 12,
                chevronOffsetY: 2
            ),
            fonts: .init(
                title: .init(Font.system(size: 12), foreground: .textPlaceholder),
                value: .init(Font.system(size: 16), foreground: .white)
            ),
            colors: .init(
                background: .black,
                divider: .divider,
                chevron: .divider,
                bottomPanelBackground: .bottomPanelBackground
            )
        ),
        header: .init(
            text: "Рассчитать кредит",
            font: .init(Font.system(size: 20).bold(), foreground: .white),
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
            toggle: .init(
                colors: .init(
                    on: .green,
                    off: .textPlaceholder
                )
            ),
            slider: .init(
                minTrackColor: .red,
                maxTrackColor: .textPlaceholder,
                thumbDiameter: 20,
                trackHeight: 2,
                maximumValue: 20.0
            )
        ),
        period: .init(titleText: "Срок кредита"),
        percent: .init(titleText: "Процентная ставка"),
        desiredAmount: .init(
            titleText: "Желаемая сумма кредита",
            maxText: "До 15 млн. ₽",
            titleTopPadding: 20,
            sliderBottomPadding: 12,
            fontValue: .init(Font.system(size: 24).bold(), foreground: .white)
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
    )
}

