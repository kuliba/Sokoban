//
//  PaymentCompletionLayoutViewConfig.swift
//
//
//  Created by Igor Malyarov on 18.02.2025.
//

import Foundation

public struct PaymentCompletionLayoutViewConfig {
    
    public let buttonsPadding: CGFloat
    public let spacing: CGFloat
    
    public init(
        buttonsPadding: CGFloat,
        spacing: CGFloat
    ) {
        self.buttonsPadding = buttonsPadding
        self.spacing = spacing
    }
}
