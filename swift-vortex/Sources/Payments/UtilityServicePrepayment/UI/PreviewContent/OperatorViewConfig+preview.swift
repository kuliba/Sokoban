//
//  OperatorLabelConfig+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

extension OperatorLabelConfig {
    
    static let preview: Self = .init(
        chevron: nil,
        height: 46,
        title: .init(
            textFont: .title3,
            textColor: .black
        ),
        subtitle: .init(
            textFont: .body,
            textColor: .gray
        ),
        spacing: 16
    )
    
    static let previewWithChevron: Self = .init(
        chevron: .preview,
        height: 46,
        title: .init(
            textFont: .title3,
            textColor: .black
        ),
        subtitle: .init(
            textFont: .body,
            textColor: .gray
        ),
        spacing: 16
    )
}

extension OperatorLabelConfig.ChevronConfig {
    
    static let preview: Self = .init(
        color: .pink,
        icon: .init(systemName: "chevron.right"),
        size: .init(width: 40, height: 40)
    )
}
