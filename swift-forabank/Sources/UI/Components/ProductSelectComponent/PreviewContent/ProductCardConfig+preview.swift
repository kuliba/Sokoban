//
//  ProductCardConfig+preview.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SharedConfigs
import SwiftUI

extension ProductCardConfig {
    
    static let preview: Self = .init(
        balance: .init(
            textFont: .caption.bold(),
            textColor: .orange
        ),
        cardSize: .init(width: 112, height: 71),
        number: .init(
            textFont: .caption.bold(),
            textColor: .blue
        ),
        title: .init(
            textFont: .caption.weight(.thin),
            textColor: .white
        ),
        shadowColor: .black.opacity(0.3)
    )
}
