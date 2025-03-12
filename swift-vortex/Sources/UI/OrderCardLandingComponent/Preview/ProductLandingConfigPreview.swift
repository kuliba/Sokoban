//
//  ProductLandingConfigPreview.swift
//  
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Foundation

extension ProductLandingConfig {
    
    static let preview: Self = .init(
        buttonsConfig: .init(
            buttonsPadding: 16,
            buttonsSpacing: 44,
            buttonsHeight: 56
        ),
        conditionButtonConfig: .init(
            icon: .bolt,
            foregroundColorDark: .red,
            foregroundColorLight: .green,
            spacing: 12,
            frame: 20,
            title: "Подробные уcловия",
            titleDark: .init(
                textFont: .body,
                textColor: .black
            ),
            titleLight: .init(
                textFont: .body,
                textColor: .white
            )
        ),
        item: .init(
            circle: 5,
            titleDark: .init(
                textFont: .body,
                textColor: .black
            ),
            titleLight: .init(
                textFont: .body,
                textColor: .white
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
                    textFont: .body,
                    textColor: .white
                )
            )
        ),
        titleDark: .init(
            textFont: .largeTitle,
            textColor: .white
        ),
        titleLight: .init(
            textFont: .largeTitle,
            textColor: .black
        )
    )
}
