//
//  DetailCellViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 20.02.2025.
//

extension DetailCellViewConfig {
    
    static let preview: Self = .init(
        insets: .init(top: 0, leading: 4, bottom: 12, trailing: 0),
        imageSize: .init(width: 24, height: 24),
        imageTopPadding: 8,
        hSpacing: 20,
        vSpacing: 4,
        title: .init(
            textFont: .footnote,
            textColor: .secondary
        ),
        value: .init(
            textFont: .headline,
            textColor: .primary
        )
    )
}
