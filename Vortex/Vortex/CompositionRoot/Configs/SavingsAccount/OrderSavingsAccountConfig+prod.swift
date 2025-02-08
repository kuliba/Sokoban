//
//  OrderSavingsAccountConfig+prod.swift
//  Vortex
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Foundation
import SavingsAccount
import SwiftUI

extension OrderSavingsAccountConfig {
    
    static let prod: Self = .init(
        amount: .init(
            amount: .init(textFont: .textH1Sb24322(), textColor: .textWhite),
            backgroundColor: .bgIconBlack,
            button: .init(
                active: .init(backgroundColor: .buttonPrimary, text: .init(textFont: .textBodyMSb14200(), textColor: .textWhite)),
                inactive: .init(backgroundColor: .buttonPrimaryDisabled, text: .init(textFont: .textBodyMSb14200(), textColor: .textWhite)), buttonHeight: 38),
            dividerColor: .bordersDivider,
            title: .init(textFont: .textH1Sb24322(), textColor: .textWhite)),
        background: .mainColorsGrayLightest,
        cornerRadius: 12,
        header: .init(text: "Оформление\nнакопительного счета", config: .init(textFont: .textH3M18240(), textColor: .textSecondary)),
        images: .init(
            back: .ic24ChevronLeft,
            checkOff: Image("Checkbox_normal"),
            checkOn: Image("Checkbox_active")),
        income: .init(
            image: .ic24Percent,
            imageSize: .init(width: 24, height: 24),
            title: .init(
                text: "Доход",
                config: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder)
            ),
            subtitle: .init(textFont: .textH4M16240(), textColor: .textSecondary)),
        linkableTexts: .init(checkBoxSize: .init(width: 24, height: 24), condition: "Я соглашаюсь с <u>Условиями</u> и ", tariff: "<u>Тарифами</u>"),
        openButton: .init(
            background: .init(active: .buttonPrimary, inactive: .buttonPrimaryDisabled),
            cornerRadius: 12,
            height: 56,
            labels: .init(open: "Открыть накопительный счет", confirm: "Подтвердить и открыть"),
            title: .init(textFont: .textH3Sb18240(), textColor: .textWhite)),
        order: .init(
            card: .init(width: 112, height: 72),
            header: .init(title: .init(textFont: .textH3Sb18240(), textColor: .textSecondary), subtitle: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder)),
            image: .ic16ArrowRightCircle,
            imageSize: .init(width: 16, height: 16),
            options: .init(
                headlines: .init(
                    open: "Открытие",
                    service: "Стоимость обслуживания"),
                config: .init(
                    title: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
                    subtitle: .init(textFont: .textH4M16240(), textColor: .textSecondary))
            )
        ),
        padding: 16,
        shadowColor: .blurBlack20,
        shimmering: .solidGrayBackground,
        topUp: .init(
            amount: .init(
                amount: .init(text: "Сумма пополнения", config: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder)),
                fee: .init(text: "Комиссия", config: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder)),
                value: .init(textFont: .textBodyMR14200(), textColor: .textSecondary)
            ),
            description: .init(text: "Пополнение доступно без комиссии\nс рублевого счета или карты ", config: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder)),
            image: .ic24MessageSquare,
            subtitle: .init(text: "Пополнить сейчас", config: .init(textFont: .textH4M16240(), textColor: .textSecondary)),
            title: .init(text: "Хотите пополнить счет?", config: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder)),
            toggle: .preview
        )
    )
}
