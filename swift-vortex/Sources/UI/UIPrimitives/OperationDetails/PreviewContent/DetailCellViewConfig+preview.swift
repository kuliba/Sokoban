//
//  DetailCellViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 20.02.2025.
//

extension DetailCellViewConfig {
    
    static let preview: Self = .init(
        labelVPadding: 6,
        imageForegroundColor: .orange,
        imageSize: .init(width: 24, height: 24),
        imagePadding: .init(top: 14, leading: 4, bottom: 0, trailing: 0),
        hSpacing: 20,
        vSpacing: 4,
        title: .init(textFont: .footnote, textColor: .secondary),
        value: .init(textFont: .headline, textColor: .primary),
        product: .preview
    )
}

extension DetailCellViewConfig.ProductConfig {
    
    static let preview: Self = .init(
        balance: .init(textFont: .body, textColor: .primary),
        description: .init(textFont: .caption, textColor: .secondary),
        hSpacing: 16,
        iconSize: .init(width: 32, height: 32),
        name: .init(textFont: .headline, textColor: .primary),
        title: .init(textFont: .footnote, textColor: .secondary),
        vStackVPadding: 6    )
}
