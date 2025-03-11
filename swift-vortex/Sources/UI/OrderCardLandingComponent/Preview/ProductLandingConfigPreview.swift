//
//  ProductLandingConfigPreview.swift
//  
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Foundation

extension ProductLandingConfig {
    
    static let preview: Self = .init(
        background: .gray,
        buttonsConfig: .init(
            buttonsPadding: 16,
            buttonsSpacing: 44,
            buttonsHeight: 56
        ),
        conditionButtonConfig: .init(
            icon: .bolt,
            spacing: 12,
            frame: 20,
            title: .init(
                text: "Подробные уcловия",
                config: .init(
                    textFont: .body,
                    textColor: .black
                )
            )
        ),
        item: .init(
            circle: 5,
            title: .init(
                textFont: .body,
                textColor: .black
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
        title: .init(
            textFont: .largeTitle,
            textColor: .black
        )
    )
}
