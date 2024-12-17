//
//  CategoryPickerSectionStateItemLabelConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHubUI

extension CategoryPickerSectionStateItemLabelConfig {
    
    static let iFora: Self = .init(
        iconBackground: .init(
            color: .mainColorsGrayLightest,
            roundedRect: .icon
        ),
        iconSize: .init(width: 24, height: 24),
        placeholder: .init(
            icon: .icon,
            title: .init(
                radius: 90,
                size: .init(width: 180, height: 14)
            ),
            spacing: 20
        ),
        spacing: 16,
        title: .init(
            textFont: .textH4R16240(),
            textColor: .textSecondary
        ),
        showAll: .init(
            text: "См. все",
            config: .init(
                textFont: .textBodyMR14200(),
                textColor: .textSecondary
            )
        )
    )
}

private extension CategoryPickerSectionStateItemLabelConfig.RoundedRect {
    
    static let icon: Self = .init(
        radius: 8,
        size: .init(width: 48, height: 48)
    )
}
