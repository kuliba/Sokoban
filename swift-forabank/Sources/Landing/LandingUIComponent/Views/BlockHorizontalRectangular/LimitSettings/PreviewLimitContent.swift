//
//  PreviewLimitContent.swift
//
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import Foundation

extension Limit {
    
    static let preview: Self = .init(
        title: "Сумма перевода",
        value: 12_345.45,
        md5Hash: ""
    )
}

extension LimitConfig {
    
    static let preview: Self = .init(
        limit: .init(
            textFont: .title.bold(),
            textColor: .black
        ),
        backgroundColor: .black.opacity(0.8),
        title: .init(
            textFont: .caption,
            textColor: .gray
        ),
        widthAndHeight: 24
    )
}
