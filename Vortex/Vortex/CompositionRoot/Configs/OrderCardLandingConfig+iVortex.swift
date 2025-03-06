//
//  OrderCardLandingConfig+iVortex.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 25.02.2025.
//

import ListLandingComponent

extension ListLandingComponent.Config {
    
    static let iVortex: Self = .init(
        background: .mainColorsGrayLightest,
        item: .init(
            title: .init(
                textFont: .textH4M16240(),
                textColor: .textSecondary
            ),
            subtitle: .init(
                textFont: .textBodyMR14180(),
                textColor: .textPlaceholder
            )
        ),
        title: .init(
            textFont: .textH3Sb18240(),
            textColor: .mainColorsBlack
        ),
        spacing: 18
    )
}
