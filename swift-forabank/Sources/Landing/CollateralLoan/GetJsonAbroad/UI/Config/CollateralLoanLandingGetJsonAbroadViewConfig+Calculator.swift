//
//  CollateralLoanLandingGetJsonAbroadViewConfig+Calculator.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI

extension CollateralLoanLandingGetJsonAbroadViewConfig {
    
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
