//
//  CategoryPickerSectionContentViewConfig+preview.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SharedConfigs

extension CategoryPickerSectionContentViewConfig {
    
    static let preview: Self = .init(
        failure: .preview,
        headerHeight: 24,
        spacing: 16,
        title: .init(
            text: "Make a Payment",
            config: .init(
                textFont: .title3.bold(),
                textColor: .primary
            ),
            leadingPadding: 20
        ),
        titlePlaceholder: .init(
            color: .gray.opacity(0.5),
            radius: 12,
            size: .init(width: 148, height: 18)
        )
    )
}

extension LabelConfig {
    
    static let preview: Self = .init(
        imageConfig: .init(
            color: .blue,
            image: .init(systemName: "magnifyingglass"),
            backgroundColor: .pink.opacity(0.4),
            backgroundSize: .init(width: 64, height: 64),
            size: .init(width: 24, height: 24)
        ),
        spacing: 24,
        textConfig: .init(
            text: "Мы не смогли загрузить данные.\nПопробуйте позже.",
            alignment: .center,
            config: .init(
                textFont: .headline.italic(),
                textColor: .green
            )
        )
    )
}
