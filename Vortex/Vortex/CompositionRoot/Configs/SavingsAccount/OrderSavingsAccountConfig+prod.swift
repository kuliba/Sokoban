//
//  OrderSavingsAccountConfig+prod.swift
//  Vortex
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Foundation
import SavingsAccount
import SwiftUI

// TODO: need update values

extension OrderSavingsAccountConfig {
    
    static let prod: Self = .init(
        amount: .init(
            amount: .init(textFont: .system(size: 24), textColor: .white),
            backgroundColor: .black.opacity(0.8),
            button: .init(
                active: .init(backgroundColor: .red, text: .init(textFont: .system(size: 14), textColor: .white)),
                inactive: .init(backgroundColor: .gray, text: .init(textFont: .system(size: 14), textColor: .white)), buttonHeight: 38),
            dividerColor: .bordersDivider,
            title: .init(textFont: .system(size: 14), textColor: .white)),
        background: .bordersDivider,
        cornerRadius: 12,
        header: .init(text: "Оформление\nнакопительного счета", config: .init(textFont: .system(size: 18), textColor: .black)),
        images: .init(
            back: .init(systemName: "chevron.backward"),
            checkOff: .init(systemName: "square"),
            checkOn: .init(systemName: "checkmark.square")),
        income: .init(
            image: .init(systemName: "percent"),
            imageSize: .init(width: 24, height: 24),
            title: .init(text: "Доход",
                         config: .init(textFont: .body, textColor: .gray)),
            subtitle: .init(textFont: .headline, textColor: .black)),
        linkableTexts: .init(checkBoxSize: .init(width: 24, height: 24), condition: "Я соглашаюсь с <u>Условиями</u> и ", tariff: "<u>Тарифами</u>"),
        openButton: .init(
            background: .init(active: .red, inactive: .gray),
            cornerRadius: 12,
            height: 56,
            labels: .init(open: "Открыть накопительный счет", confirm: "Подтвердить и открыть"),
            title: .init(textFont: .body, textColor: .white)),
        order: .init(
            card: .init(width: 112, height: 72),
            header: .init(title: .init(textFont: .body, textColor: .black), subtitle: .init(textFont: .subheadline, textColor: .gray)),
            image: .init(systemName: "arrow.forward"),
            imageSize: .init(width: 16, height: 16),
            options: .init(headlines: .init(
                open: "Открытие",
                service: "Стоимость обслуживания"), config: .init(title: .init(textFont: .body, textColor: .gray), subtitle: .init(textFont: .caption2, textColor: .black)))
        ),
        padding: 16,
        shimmering: .solidGrayBackground,
        topUp: .init(
            amount: .init(
                amount: .init(text: "Сумма пополнения", config: .init(textFont: .system(size: 14), textColor: .gray)),
                fee: .init(text: "Комиссия", config: .init(textFont: .system(size: 14), textColor: .gray)),
                value: .init(textFont: .system(size: 14), textColor: .black)
            ),
            description: .init(text: "Пополнение доступно без комиссии\nс рублевого счета или карты ", config: .init(textFont: .system(size: 12), textColor: .gray)),
            image: .init(systemName: "message"),
            subtitle: .init(text: "Пополнить сейчас", config: .init(textFont: .system(size: 16), textColor: .black)),
            title: .init(text: "Хотите пополнить счет?", config: .init(textFont: .system(size: 14), textColor: .gray)),
            toggle: .preview
        )
    )
}
