//
//  CategoryPickerSectionStateItemLabelConfig+preview.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHubUI

extension CategoryPickerSectionStateItemLabelConfig {
    
    static let preview: Self = .init(
        iconBackground: .init(
            color: .gray.opacity(0.1), // main colors/Gray lightest,
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
        title: .init(textFont: .headline, textColor: .primary),
        showAll: .init(
            text: "show all".uppercased(),
            config: .init(textFont: .caption, textColor: .blue)
        )
    )
}

private extension CategoryPickerSectionStateItemLabelConfig.RoundedRect {
    
    static let icon: Self = .init(
        radius: 8,
        size: .init(width: 48, height: 48)
    )
}
