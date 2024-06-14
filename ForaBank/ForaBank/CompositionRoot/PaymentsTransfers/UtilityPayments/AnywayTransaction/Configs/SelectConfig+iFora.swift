//
//  SelectConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import PaymentComponents

extension SelectConfig {
    
    static let iFora: Self = .init(
        title: "Title",
        titleConfig: .secondary,
        placeholder: "placeholder",
        placeholderConfig: .placeholder,
        backgroundIcon: .buttonSecondary,
        foregroundIcon: .mainColorsWhite,
        icon: .init(systemName: "circle"),
        isSearchable: true,
        optionConfig: .iFora
    )
}

extension SelectConfig.OptionConfig {
    
    static let iFora: Self = .init(
        icon: .init(systemName: "circle"),
        foreground: .mainColorsWhite,
        background: .buttonSecondary,
        selectIcon: .init(systemName: "checkmark"),
        selectForeground: .textSecondary,
        selectBackground: .buttonSecondary,
        mainBackground: .buttonSecondary,
        size: 24
    )
}
