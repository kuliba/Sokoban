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
        backgroundColor: .mainColorsGrayLightest,
        bankDefault: .iFora,
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
