//
//  CategoryPickerSectionStateItemLabelConfig+preview.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

extension CategoryPickerSectionStateItemLabelConfig {
    
    static let preview: Self = .init(
        iconBackground: .init(
            color: .gray.opacity(0.1), // main colors/Gray lightest,
            radius: 8,
            size: .init(width: 48, height: 48)
        ),
        iconSize: .init(width: 24, height: 24),
        placeholderSpacing: 20,
        placeholderRadius: 90,
        placeholderSize: .init(width: 180, height: 14),
        spacing: 16,
        title: .init(textFont: .headline, textColor: .green),
        showAll: .init(
            text: "show all".uppercased(),
            config: .init(textFont: .caption, textColor: .blue)
        )
    )
}
