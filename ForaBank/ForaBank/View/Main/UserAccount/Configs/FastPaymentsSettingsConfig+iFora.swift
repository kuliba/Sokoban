//
//  FastPaymentsSettingsConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.02.2024.
//

import FastPaymentsSettings
import SwiftUI

extension FastPaymentsSettingsConfig {
    
    static let iVortex: Self = .init(
        accountLinking: .init(
            image: .ic24Subscriptions,
            title: .secondary
        ),
        backgroundColor: .mainColorsGrayLightest,
        bankDefault: .iVortex, 
        carousel: .iVortexSmall,
        consentList: .iVortex, 
        deleteDefaultBank: .iVortex,
        paymentContract: .iVortex,
        productSelect: .iVortex
    )
}

extension DeleteDefaultBankConfig {
    
    static let iVortex: Self = .init(
        title: "Удалить банк по умолчанию",
        titleConfig: .init(textFont: .textH4M16240(), textColor: .textSecondary),
        description: "Вы можете удалить любой банк ранее установленный по умолчанию",
        descriptionConfig: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
        iconConfig: .init(icon: .ic24Bank, foreground: .textPlaceholder),
        buttonConfig: .init(icon: .ic24CircleClose, foreground: .textPlaceholder),
        backgroundView: .mainColorsGrayLightest
    )
}
extension BankDefaultConfig {
    
    static let iVortex: Self = .init(
        logo: .init(
            backgroundColor: .mainColorsRed,
            image: .init("vortex logo")
        ),
        title: .secondary,
        toggleConfig: .init(
            onDisabled: .init(toggleColor: .buttonGreenBlock),
            offEnabled: .init(toggleColor: .iconBlack),
            offDisabled: .init(toggleColor: .iconGray)
        ),
        subtitle: .placeholder
    )
}

extension ConsentListConfig {
    
    static let iVortex: Self = .init(
        chevron: .init(
            image: .ic24ChevronDown,
            color: .iconGray,
            title: .placeholder
        ),
        collapsedBankList: .secondary,
        errorIcon: .init(
            backgroundColor: .bordersDivider,
            image: .ic24Search
        ),
        expandedConsent: .iVortex,
        image: .ic24Bank,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        )
    )
}

extension ExpandedConsentConfig {
    
    static let iVortex: Self = .init(
        apply: .init(
            backgroundColor: .mainColorsGrayLightest,
            title: .secondary
        ),
        bank: .secondary,
        checkmark: .init(
            backgroundColor: .iconWhite,
            borderColor: .buttonSecondaryHover,
            color: .iconBlack,
            image: .ic16Check
        ),
        noMatch: .init(
            image: .init(
                backgroundColor: .bordersDivider,
                image: .ic24Search
            ),
            title: .init(
                textFont: .textBodySR12160(),
                textColor: .textPlaceholder
            )
        )
    )
}

extension PaymentContractConfig {
    
    static let iVortex: Self = .init(
        active: .init(
            title: .secondary,
            toggleColor: .systemColorActive,
            subtitle: .placeholder
        ),
        inactive: .init(
            title: .secondary,
            toggleColor: .iconBlack,
            subtitle: .placeholder
        )
    )
}
