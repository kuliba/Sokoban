//
//  ProductPreview.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Foundation

extension Product {
    
    static let product: Self = .init(
        action: .init(
            fallbackURL: "",
            target: "",
            type: ""
        ),
        imageURL: "",
        items: [
            .init(
                bullet: true,
                title: "0 ₽. Условия обслуживания Кешбэк до 10 000 ₽ в месяц"
            ),
            .init(
                bullet: true,
                title: "5% выгода при покупке топлива"
            ),
            .init(
                bullet: true,
                title: "5% на категории сезона"
            ),
            .init(
                bullet: true,
                title: "от 0,5% до 1% кешбэк на остальные покупки**"
            ),
            .init(
                bullet: true,
                title: "8% годовых при сумме остатка от 500 001 ₽ на карте"
            )
        ],
        terms: "",
        title: "Карта МИР «Все включено»"
    )
}
