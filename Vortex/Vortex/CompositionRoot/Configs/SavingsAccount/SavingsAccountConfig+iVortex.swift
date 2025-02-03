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
                title: .init(textFont: .textH4M16240(), textColor: .textSecondary),
                subtitle: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder)),
            title: .init(textFont: .textH3M18240(), textColor: .textSecondary)),
        offsetForDisplayHeader: 100,
        paddings: .init(
            negativeBottomPadding: 60,
            vertical: 16,
            list: .init(horizontal: 16, vertical: 12)),
        spacing: 16,
        questionHeight: 64
    )
}
