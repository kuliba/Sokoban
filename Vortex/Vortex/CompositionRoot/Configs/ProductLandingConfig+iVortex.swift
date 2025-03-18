//
//  ProductLandingConfig+iVortex.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 12.03.2025.
//

import OrderCardLandingComponent

extension ProductLandingConfig {
    
    static let iVortex: Self = .init(
        buttonsConfig: .init(
            buttonsPadding: 16,
            buttonsSpacing: 44,
            buttonsHeight: 56
        ),
        conditionButtonConfig: .init(
            icon: .ic24Info,
            foregroundColorDark: .textSecondary,
            foregroundColorLight: .textWhite,
            spacing: 12,
            frame: 20,
            title: "Подробные уcловия",
            titleDark: .init(
                textFont: .textBodyMR14200(),
                textColor: .textWhite
            ),
            titleLight: .init(
                textFont: .textBodyMR14200(),
                textColor: .textSecondary
            )
        ),
        item: .init(
            circle: 5,
            titleDark: .init(
                textFont: .textBodyMR14200(),
                textColor: .textWhite
            ),
            titleLight: .init(
                textFont: .textBodyMR14200(),
                textColor: .textSecondary
            ),
            itemPadding: 16
        ),
        imageCoverConfig: .init(
            height: 236,
            cornerRadius: 12,
            horizontalPadding: 16,
            verticalPadding: 12
        ),
        orderButtonConfig: .init(
            background: .buttonPrimary,
            cornerRadius: 8,
            title: .init(
                text: "Заказать",
                config: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .textWhite
                )
            )
        ),
        titleDark: .init(
            textFont: .marketingH0B40X480(),
            textColor: .textSecondary
        ),
        titleLight: .init(
            textFont: .marketingH0B40X480(),
            textColor: .textWhite
        )
    )
}
