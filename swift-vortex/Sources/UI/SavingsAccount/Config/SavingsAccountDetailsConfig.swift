//
//  SavingsAccountDetailsConfig.swift
//
//
//  Created by Andryusina Nataly on 02.12.2024.
//

import SharedConfigs
import SwiftUI

public struct SavingsAccountDetailsConfig: Equatable {
    
    public let chevronDown: Image
    public let colors: Colors
    public let cornerRadius: CGFloat
    public let days: TextConfig
    public let heights: Heights
    public let info: Image
    public let interestDate: TextConfig
    public let interestTitle: TextConfig
    public let interestSubtitle: TextConfig
    public let padding: CGFloat
    public let period: TextConfig
    public let progressColors: [Color]
    public let texts: Texts
    
    public init(
        chevronDown: Image,
        colors: Colors,
        cornerRadius: CGFloat,
        days: TextConfig,
        heights: Heights,
        info: Image,
        interestDate: TextConfig,
        interestTitle: TextConfig,
        interestSubtitle: TextConfig,
        padding: CGFloat,
        period: TextConfig,
        progressColors: [Color],
        texts: Texts
    ) {
        self.chevronDown = chevronDown
        self.colors = colors
        self.cornerRadius = cornerRadius
        self.days = days
        self.heights = heights
        self.info = info
        self.interestDate = interestDate
        self.interestTitle = interestTitle
        self.interestSubtitle = interestSubtitle
        self.padding = padding
        self.period = period
        self.progressColors = progressColors
        self.texts = texts
    }
    
    public struct Heights: Equatable {
        
        public let big: CGFloat
        public let header: CGFloat
        public let interest: CGFloat
        public let period: CGFloat
        public let progress: CGFloat
        public let small: CGFloat
        
        public init(
            big: CGFloat,
            header: CGFloat,
            interest: CGFloat,
            period: CGFloat,
            progress: CGFloat,
            small: CGFloat
        ) {
            self.big = big
            self.header = header
            self.interest = interest
            self.period = period
            self.progress = progress
            self.small = small
        }
    }
    
    public struct Colors: Equatable {
        
        public let background: Color
        public let chevron: Color
        public let progress: Color
        public let shimmering: Color
        
        public init(
            background: Color,
            chevron: Color,
            progress: Color,
            shimmering: Color
        ) {
            self.background = background
            self.chevron = chevron
            self.progress = progress
            self.shimmering = shimmering
        }
    }
    
    public struct Texts: Equatable {
        
        public let currentInterest: String
        public let header: TextWithConfig
        public let minBalance: String
        public let paidInterest: String
        public let per: String
        
        public let days: String
        public let interestDate: String
        public let period: String
        
        public init(
            currentInterest: String,
            header: TextWithConfig,
            minBalance: String,
            paidInterest: String,
            per: String,
            days: String,
            interestDate: String,
            period: String
        ) {
            self.currentInterest = currentInterest
            self.header = header
            self.minBalance = minBalance
            self.paidInterest = paidInterest
            self.per = per
            self.days = days
            self.interestDate = interestDate
            self.period = period
        }
    }
}
