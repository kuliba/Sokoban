//
//  OrderCardViewConfig.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SwiftUI

public struct OrderCardViewConfig {
    
    public let cardType: CardTypeViewConfig
    public let formSpacing: CGFloat
    public let messages: MessageViewConfig
    public let product: ProductConfig
    public let shimmeringColor: Color
    public let roundedConfig: RoundedConfig
    
    public init(
        cardType: CardTypeViewConfig,
        formSpacing: CGFloat,
        messages: MessageViewConfig,
        product: ProductConfig,
        shimmeringColor: Color,
        roundedConfig: RoundedConfig
    ) {
        self.cardType = cardType
        self.formSpacing = formSpacing
        self.messages = messages
        self.product = product
        self.shimmeringColor = shimmeringColor
        self.roundedConfig = roundedConfig
    }
}
