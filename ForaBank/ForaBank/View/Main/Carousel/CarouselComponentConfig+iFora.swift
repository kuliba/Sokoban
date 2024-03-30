//
//  CarouselComponentConfig+iFora.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 30.03.2024.
//

import CarouselComponent
import SwiftUI

extension CarouselComponentConfig {
    
    static let iForaSmall: Self = .init(
        carousel: .init(
            item: .init(
                spacing: 13,
                horizontalPadding: 20
            ),
            group: .init(
                spacing: 8,
                buttonFont: .textBodyMM14200(),
                shadowForeground: Color(hex: "#1C1C1C"),
                buttonForegroundPrimary: .bordersDivider,
                buttonForegroundSecondary: .textSecondary,
                buttonIconForeground: .textSecondary
            ),
            spoilerImage: .ic24ChevronsLeft,
            separatorForeground: .bordersDivider,
            productDimensions: .small),
              selector: .init(
                optionConfig: .init(
                    frameHeight: 24,
                    textFont: .textBodySR12160(),
                    textForeground: .textPlaceholder,
                    textForegroundSelected: .textSecondary,
                    shapeForeground: .white,
                    shapeForegroundSelected: .mainColorsGrayLightest
            ),
            itemSpacing: 8
        )
    )
}
