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
    
    struct Calculator {
        
        let root: Root
        let header: Header
        let salary: Salary
        let period: Period
        let percent: Percent
        let desiredAmount: DesiredAmount
        let monthlyPayment: MonthlyPayment
        let info: Info
        let deposit: Deposit

        init(
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
        
        struct Root {
            
            let layouts: Layouts
            let fonts: Fonts
            let colors: Colors

            init(layouts: Layouts, fonts: Fonts, colors: Colors) {
                self.layouts = layouts
                self.fonts = fonts
                self.colors = colors
            }
            
            struct Layouts {
                
                let height: CGFloat
                let contentLeadingPadding: CGFloat
                let contentTrailingPadding: CGFloat
                let middleSectionSpacing: CGFloat
                let spacingBetweenTitleAndValue: CGFloat
                let chevronSpacing: CGFloat
                let bottomPanelCornerRadius: CGFloat
                let chevronOffsetY: CGFloat
                
                init(
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
            
            struct Fonts {
                
                let title: FontConfig
                let value: FontConfig
                
                init(title: FontConfig, value: FontConfig) {
                    self.title = title
                    self.value = value
                }
            }
            
            struct Colors {
                
                let background: Color
                let divider: Color
                let chevron: Color
                let bottomPanelBackground: Color
                
                init(
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
        
        struct Header {

            let text: String
            let font: FontConfig
            let topPadding: CGFloat
            let bottomPadding: CGFloat
            
            init(text: String, font: FontConfig, topPadding: CGFloat, bottomPadding: CGFloat) {
                
                self.text = text
                self.font = font
                self.topPadding = topPadding
                self.bottomPadding = bottomPadding
            }
        }
        
        struct Salary {
            
            let text: String
            let font: FontConfig
            let leadingPadding: CGFloat
            let trailingPadding: CGFloat
            let bottomPadding: CGFloat
            let toggleTrailingPadding: CGFloat
            let toggle: ToggleConfig
            let slider: Slider
            
            init(
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
        
        struct Slider {
            
            let minTrackColor: Color
            let maxTrackColor: Color
            let thumbDiameter: CGFloat
            let trackHeight: CGFloat
            let maximumValue: Float
            
            init(
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
        
        struct Period {
            
            let titleText: String
            
            init(titleText: String) {
                
                self.titleText = titleText
            }
        }
        
        struct Percent {
            
            let titleText: String

            init(titleText: String) {
                
                self.titleText = titleText
            }
        }
        
        struct Deposit {
            
            let titleText: String
            let titleTopPadding: CGFloat

            init(titleText: String, titleTopPadding: CGFloat) {
                self.titleText = titleText
                self.titleTopPadding = titleTopPadding
            }
        }
        
        struct DesiredAmount {
            
            let titleText: String
            let maxText: String
            let titleTopPadding: CGFloat
            let sliderBottomPadding: CGFloat
            let fontValue: FontConfig

            init(
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
        
        struct MonthlyPayment {
            
            let titleText: String
            let titleTopPadding: CGFloat
            let valueTopPadding: CGFloat
            
            init(titleText: String, titleTopPadding: CGFloat, valueTopPadding: CGFloat) {
                
                self.titleText = titleText
                self.titleTopPadding = titleTopPadding
                self.valueTopPadding = valueTopPadding
            }
        }
        
        struct Info {
            
            let titleText: String
            let titleTopPadding: CGFloat
            let titleBottomPadding: CGFloat
            
            init(
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

