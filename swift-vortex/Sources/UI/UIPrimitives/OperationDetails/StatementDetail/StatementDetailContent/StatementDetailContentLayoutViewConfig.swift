//
//  StatementDetailContentLayoutViewConfig.swift
//
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SharedConfigs
import SwiftUI

public struct StatementDetailContentLayoutViewConfig: Equatable {
    
    public let formattedAmount: TextConfig
    public let formattedDate: TextConfig
    public let merchantName: TextConfig
    public let purpose: TextConfig
    public let purposeHeight: CGFloat
    public let spacing: CGFloat
    public let status: Status
    public let frames: Frames
    public let placeholderColors: PlaceholderColors
    
    public init(
        formattedAmount: TextConfig,
        formattedDate: TextConfig,
        merchantName: TextConfig,
        purpose: TextConfig,
        purposeHeight: CGFloat,
        spacing: CGFloat,
        status: Status,
        frames: Frames,
        placeholderColors: PlaceholderColors
    ) {
        self.formattedAmount = formattedAmount
        self.formattedDate = formattedDate
        self.merchantName = merchantName
        self.purpose = purpose
        self.purposeHeight = purposeHeight
        self.spacing = spacing
        self.status = status
        self.frames = frames
        self.placeholderColors = placeholderColors
    }
}

extension StatementDetailContentLayoutViewConfig {
    
    public struct Status: Equatable {
        
        public let font: Font
        public let completed: Color
        public let inflight: Color
        public let rejected: Color
        
        public init(
            font: Font,
            completed: Color,
            inflight: Color,
            rejected: Color
        ) {
            self.font = font
            self.completed = completed
            self.inflight = inflight
            self.rejected = rejected
        }
    }
    
    public struct Frames: Equatable {
        
        public let button: CGSize
        public let buttonCircle: CGSize
        public let buttonText: CGSize
        public let formattedAmount: CGSize
        public let formattedDate: CGSize
        public let logoWidth: CGFloat
        public let purpose: CGSize
        public let status: CGSize
        
        public init(
            button: CGSize,
            buttonCircle: CGSize,
            buttonText: CGSize,
            formattedAmount: CGSize,
            formattedDate: CGSize,
            logo: CGFloat,
            purpose: CGSize,
            status: CGSize
        ) {
            self.button = button
            self.buttonCircle = buttonCircle
            self.buttonText = buttonText
            self.formattedAmount = formattedAmount
            self.formattedDate = formattedDate
            self.logoWidth = logo
            self.purpose = purpose
            self.status = status
        }
    }
    
    public struct PlaceholderColors: Equatable {
        
        public let button: Color
        public let logo: Color
        public let text: Color
        
        public init(
            button: Color,
            // Blur/Placeholder
            logo: Color,
            // Main colors/Gray lightest
            text: Color // Blur/Placeholder white text
        ) {
            self.button = button
            self.logo = logo
            self.text = text
        }
    }
}
