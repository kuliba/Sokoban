//
//  ProductConfig.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SharedConfigs
import SwiftUI

public struct ProductConfig {
    
    public let padding: CGFloat
    public let title: TextConfig
    public let subtitle: TextConfig
    public let optionTitle: TextConfig
    public let optionSubtitle: TextConfig
    public let openOptionTitle: String
    public let serviceOptionTitle: String
    public let shimmeringColor: Color
    public let orderOptionIcon: Image
    public let cornerRadius: CGFloat
    public let background: Color
    
    public init(
        padding: CGFloat,
        title: TextConfig,
        subtitle: TextConfig,
        optionTitle: TextConfig,
        optionSubtitle: TextConfig,
        openOptionTitle: String = "Открытие",
        serviceOptionTitle: String = "Стоимость обслуживания",
        shimmeringColor: Color,
        orderOptionIcon: Image,
        cornerRadius: CGFloat,
        background: Color
    ) {
        self.padding = padding
        self.title = title
        self.subtitle = subtitle
        self.optionTitle = optionTitle
        self.optionSubtitle = optionSubtitle
        self.openOptionTitle = openOptionTitle
        self.serviceOptionTitle = serviceOptionTitle
        self.shimmeringColor = shimmeringColor
        self.orderOptionIcon = orderOptionIcon
        self.cornerRadius = cornerRadius
        self.background = background
    }
}
