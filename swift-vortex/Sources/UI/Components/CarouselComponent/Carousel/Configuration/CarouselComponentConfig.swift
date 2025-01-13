//
//  CarouselComponentConfig.swift
//
//
//  Created by Disman Dmitry on 14.02.2024.
//

import SwiftUI
import Tagged

public struct CarouselComponentConfig {
    
    public let carousel: CarouselConfig
    public let selector: SelectorConfig
    
    public init(
        carousel: CarouselConfig,
        selector: SelectorConfig
    ) {
        self.carousel = carousel
        self.selector = selector
    }
}

public extension CarouselComponentConfig {
    
    static let preview: Self = .init(
        carousel: .init(
            item: .init(
                spacing: 13,
                horizontalPadding: 20
            ),
            group: .init(
                spacing: 8,
                buttonFont: .footnote,
                shadowForeground: Color(red: 0.11, green: 0.11, blue: 0.11),
                buttonForegroundPrimary: Color(red: 0.91, green: 0.92, blue: 0.92),
                buttonForegroundSecondary: Color(red: 28/255, green: 28/255, blue: 28/255),
                buttonIconForeground: Color(red: 0.91, green: 0.92, blue: 0.92)
            ),
            spoilerImage: Image(systemName: "chevron.left.2"),
            separatorForeground: Color(red: 0.91, green: 0.92, blue: 0.92),
            productDimensions: .small),
        selector: .init(
            optionConfig: .init(
                frameHeight: 24,
                textFont: .caption2,
                textForeground: Color(red: 0.6, green: 0.6, blue: 0.6),
                textForegroundSelected: Color(red: 0.11, green: 0.11, blue: 0.11),
                shapeForeground: .white,
                shapeForegroundSelected: Color(red: 0.96, green: 0.96, blue: 0.96)
            ),
            itemSpacing: 8
        )
    )
}
