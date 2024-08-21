//
//  CategoryPickerSectionContentViewConfig+preview.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

extension CategoryPickerSectionContentViewConfig {
    
    static let preview: Self = .init(
        headerHeight: 24,
        title: .init(
            text: "Make a Payment",
            config: .init(
                textFont: .title3.bold(),
                textColor: .green
            )
        ),
        titlePlaceholder: .init(
            color: .gray.opacity(0.5),
            radius: 12,
            size: .init(width: 148, height: 18)
        )
    )
}
