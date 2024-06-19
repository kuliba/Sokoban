//
//  SelectConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import PaymentComponents

extension SelectConfig {
    
    static func iFora(title: String, placeholder: String) -> Self{
     
        .init(
            title: title,
            titleConfig: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder),
            placeholder: placeholder,
            placeholderConfig: .init(textFont: .textBodyMR14180(), textColor: .textPlaceholder),
            backgroundIcon: .clear,
            foregroundIcon: .iconGray,
            icon: .ic24FileHash,
            isSearchable: true,
            optionConfig: .iFora
        )
    }
}

extension SelectConfig.OptionConfig {
    
    static let iFora: Self = .init(
        icon: .ic24RadioDefolt,
        foreground: .buttonSecondaryHover,
        background: .clear,
        selectIcon: .ic24RadioChecked,
        selectForeground: .buttonPrimary,
        selectBackground: .clear,
        mainBackground: .mainColorsGrayLightest,
        size: 24
    )
}
