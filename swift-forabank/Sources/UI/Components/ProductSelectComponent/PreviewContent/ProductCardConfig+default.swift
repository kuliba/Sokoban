//
//  ProductCardConfig+default.swift
//  
//
//  Created by Igor Malyarov on 14.12.2023.
//

import PrimitiveComponents
import SwiftUI

extension ProductCardConfig {
    
    static let `default`: Self = .init(
        balance: .init(
            textFont: .caption.bold(),
            textColor: .orange
        ),
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
