//
//  OrderCardViewConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.02.2025.
//

import OrderCard

extension OrderCardViewConfig {
    
    static let iVortex: Self = .init(
        cardType: .iVortex,
        formSpacing: 15,
        messages: .iVortex,
        product: .iVortex,
        shimmeringColor: .gray, // TODO: fix according to design
        roundedConfig: .iVortex
    )
}

extension CardTypeViewConfig {
    
    static let iVortex: Self = .init(
        backgroundColorIcon: .bgIconDeepPurpleMedium,
        icon: .ic24CreditCard,
        subtitle: .init(
            text: "Тип носителя",
            config: .init(
                textFont: .textBodyMR14180(),
                textColor: .textPlaceholder
            )
        ),
        title: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        )
    )
}

extension MessageViewConfig {
    
    static let iVortex: Self = .init(
        icon: .ic24MessageSquare,
        title: .init(
            text: "Способ уведомлений",
            config: .init(
                textFont: .textBodyMR14180(),
                textColor: .textPlaceholder
            )
        ),
        subtitle: .init(
            text: "Пуши и смс",
            config: .init(
                textFont: .textH4M16240(),
                textColor: .textSecondary
            )
        ),
        description: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ),
        linkableText: .init(
            text: "Присылаем пуш-уведомления, если не доходят - отправляем смс. С <u>тарифами</u> за услугу согласен.",
            tag: ("<u>", "</u>"),
            tariff: "link" //TOOD: setup link
        ),
        toggle: .init(colors: .init(on: .systemColorActive, off: .black))
    )
}

extension ProductConfig {
    
    static let iVortex: Self = .init(
        padding: 16,
        title: .init(
            textFont: .textH3Sb18240(),
            textColor: .mainColorsBlack
        ),
        subtitle: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ),
        optionTitle: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ),
        optionSubtitle: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        ),
        shimmeringColor: .gray,
        // TODO: fix according to design
        orderOptionIcon: .ic16ArrowRightCircle,
        cornerRadius: 12,
        background: .mainColorsGrayLightest
    )
}

extension RoundedConfig {
    
    static let iVortex: Self = .init(
        padding: 16,
        cornerRadius: 12,
        background: .mainColorsGrayLightest
    )
}
