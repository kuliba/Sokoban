//
//  GetC2BSubResponse+preview.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public extension GetC2BSubResponse {
    
    static let control: Self = .init(
        title: "Управление подписками",
        explanation: [
            "У Вас нет активных подписок.",
            "Для активации перейдите в приложения ваших любимых магазинов и активируйте привязку счета.",
            "Деньги в таком случае будут списываться автоматически."
        ],
        details: .list([
            .init(
                product: .card,
                subscriptions: [
                    .preview,
                    .init(
                        token: "aaaada956d884cf5b836d5642452044b",
                        brandIcon: .svg("aaaa1e25a275e3f04ae189f4a538536a"),
                        brandName: "Дом у цветов",
                        purpose: "Подписка на получение…",
                        cancelAlert: "Вы действительно хотите отключить подписку Дом у цветов?"
                    ),
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
