//
//  ProductLandingConfig+iVortex.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 12.03.2025.
//

import OrderCardLandingComponent

extension ProductLandingConfig {
    
    static let iVortex: Self = .init(
        background: .white,
        buttonsConfig: .init(
            buttonsPadding: 16,
            buttonsSpacing: 44,
            buttonsHeight: 56
        ),
        conditionButtonConfig: .init(
            icon: .cardPlaceholder,
            spacing: 12,
            frame: 20,
            title: .init(
                text: "Подробные уcловия",
                config: .init(
                    textFont: .textBodyMR14200(),
                    textColor: .textSecondary
                )
            )
        ),
        item: .init(
            circle: 5,
            title: .init(
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
            background: .red,
            cornerRadius: 8,
            title: .init(
                text: "Заказать",
                config: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .textWhite
                )
            )
        ),
        title: .init(
            textFont: .marketingH0B40X480(),
            textColor: .textSecondary
        )
    )
}
