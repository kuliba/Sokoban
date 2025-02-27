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
    public let logoWidth: CGFloat
    public let merchantName: TextConfig
    public let purpose: TextConfig
    public let purposeHeight: CGFloat
    public let spacing: CGFloat
    public let status: Status
    
    public init(
        formattedAmount: TextConfig,
        formattedDate: TextConfig,
        logoWidth: CGFloat,
        merchantName: TextConfig,
        purpose: TextConfig,
        purposeHeight: CGFloat,
        spacing: CGFloat,
        status: Status
    ) {
        self.formattedAmount = formattedAmount
        self.formattedDate = formattedDate
        self.logoWidth = logoWidth
        self.merchantName = merchantName
        self.purpose = purpose
        self.purposeHeight = purposeHeight
        self.spacing = spacing
        self.status = status
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
}
