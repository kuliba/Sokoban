//
//  GetC2BSubResponse+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 25.01.2024.
//

import FastPaymentsSettings

extension GetC2BSubResponse {
    
    static let control: Self = .init(
        title: "Управление подписками",
        explanation: [
            "У Вас нет активных подписок.",
            "Для активации перейдите в приложения ваших любимых магазинов и активируйте привязку счета.",
            "Деньги в таком случае будут списываться автоматически."
        ],
        details: .list([
            .init(
                productID: "10000198241",
                productType: .card,
                productTitle: "Карта списания",
                subscriptions: [
                    .init(
                        subscriptionToken: "161fda956d884cf5b836d5642452044b",
                        brandIcon: "b8b31e25a275e3f04ae189f4a538536a",
                        brandName: "Цветы  у дома",
                        subscriptionPurpose: "Функциональная ссылка для теста №563",
                        cancelAlert: "Вы действительно хотите отключить подписку Цветы  у дома?"
                    )
                ]
            )
        ])
    )
    
    static let empty: Self = .init(
        title: "Управление подписками",
        explanation: [
            "У Вас нет активных подписок.",
            "Для активации перейдите в приложения ваших любимых магазинов и активируйте привязку счета.",
            "Деньги в таком случае будут списываться автоматически."
        ],
        details: .empty
    )
}
