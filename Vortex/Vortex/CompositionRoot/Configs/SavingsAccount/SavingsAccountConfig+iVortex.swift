//
//  SavingsAccountConfig+iVortex.swift
//  Vortex
//
//  Created by Andryusina Nataly on 15.01.2025.
//

import Foundation
import SavingsAccount
import SwiftUI

extension SavingsAccountConfig {
    
    static let iVortex: Self = .init(
        backImage: .ic24ChevronLeft,
        bannerHeight: 703,
        chevronDownImage: .ic24ChevronDown,
        cornerRadius: 16,
        continueButton: .init(
            background: .buttonPrimary,
            cornerRadius: 12,
            height: 56,
            label: "Продолжить",
            title: .init(textFont: .textH3Sb18240(), textColor: .textWhite)
        ),
        divider: .blurMediumGray30,
        icon: .init(leading: 8, widthAndHeight: 40),
        list: .init(
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
            title: .init(textFont: .textH3M18240(), textColor: .textSecondary),
            paddings: .init(horizontal: 16, vertical: 16),
            spacing: 18
        ),
        offsetForDisplayHeader: 100,
        paddings: .init(
            negativeBottomPadding: 60,
            vertical: 16,
            list: .init(horizontal: 16, vertical: 16)),
        spacing: 16,
        questions: .init(height: 64, title: .init(textFont: .textBodyMR14200(), textColor: .textSecondary))
    )
}

extension SavingsAccountInfoConfig {
    
    static let iVortex: Self = .init(
        disable: .init(color: .textPlaceholder, text: .init(textFont: .textBodyMR14200(), textColor: .textPlaceholder)),
        enable: .init(color: .systemColorActive, text: .init(textFont: .textBodyMR14200(), textColor: .textSecondary)),
        imageSize: .init(width: 24, height: 24),
        paddings: .init(top: 0, leading: 16, bottom: 40, trailing: 16),
        title: .init(textFont: .textH3Sb18240(), textColor: .textSecondary)
    )
}

extension SavingsAccountInfo {
    
    static let iVortex: Self = .init(
        list: .iVortex,
        title: "Тестовый заголовок"
    )
}

extension Array where Element == SavingsAccountInfo.Item {
    
    static let iVortex: Self = [
        .init(enable: true, image: .ic16Check, title: "• Расчёт процентов является предварительным"),
        .init(enable: true, image: .ic16Check, title: "• Рассчитывается по состоянию на конец текущего месяца, исходя из фактического минимального остатка. При его изменении сумма к выплате по итогам месяца может измениться"),
        .init(enable: true, image: .ic16Check, title: "• Максимальный остаток, на который начисляются проценты, не должен превышать 1 500 000 рублей")
    ]
}
