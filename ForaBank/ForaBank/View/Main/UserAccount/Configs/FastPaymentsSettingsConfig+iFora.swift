//
//  FastPaymentsSettingsConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.02.2024.
//

import FastPaymentsSettings
import SwiftUI

extension FastPaymentsSettingsConfig {
    
    static let iFora: Self = .init(
        accountLinking: .init(
            image: .ic24Subscriptions,
            title: .secondary
        ),
        backgroundColor: .mainColorsGrayLightest,
        bankDefault: .iFora, 
        carousel: .iForaSmall,
        consentList: .iFora,
        paymentContract: .iFora,
        productSelect: .iFora
    )
}

extension BankDefaultConfig {
    
    static let iFora: Self = .init(
        logo: .init(
            backgroundColor: .mainColorsRed,
            image: .init("fora logo")
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
    
    static let iFora: Self = .init(
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
        expandedConsent: .iFora,
        image: .ic24Bank,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        )
    )
}

extension ExpandedConsentConfig {
    
    static let iFora: Self = .init(
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
    
    static let iFora: Self = .init(
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
