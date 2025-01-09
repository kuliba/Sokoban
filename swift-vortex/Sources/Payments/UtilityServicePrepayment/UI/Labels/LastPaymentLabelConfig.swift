//
//  LastPaymentLabelConfig.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import Foundation
import SharedConfigs

public struct LastPaymentLabelConfig {
    
    let amount: TextConfig
    let frameHeight: CGFloat
    let iconSize: CGFloat
    let title: TextConfig
    
    public init(
        amount: TextConfig,
        frameHeight: CGFloat,
        iconSize: CGFloat,
        title: TextConfig
    ) {
        self.amount = amount
        self.frameHeight = frameHeight
        self.iconSize = iconSize
        self.title = title
    }
}
