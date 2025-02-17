//
//  HeaderViewConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import SwiftUI
import SharedConfigs

public struct HeaderViewConfig {

    let title: TextConfig
    let optionPlaceholder: Color
    let cardHorizontalBackground: Color
    let cardHorizontListConfig: OrderCardHorizontalConfig
    
    public init(
        title: TextConfig,
        optionPlaceholder: Color,
        cardHorizontalBackground: Color,
        cardHorizontListConfig: OrderCardHorizontalConfig
    ) {
        self.title = title
        self.optionPlaceholder = optionPlaceholder
        self.cardHorizontalBackground = cardHorizontalBackground
        self.cardHorizontListConfig = cardHorizontListConfig
    }
}
