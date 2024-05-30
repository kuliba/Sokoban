//
//  Config+preview.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import PaymentComponents
import SwiftUI

extension Config {
    
    static let preview: Self = .init(
        amount: .preview,
        background: .preview,
        button: .preview,
        carousel: .preview,
        info: .preview,
        productSelect: .preview
    )
}

extension Config.Background {
    
    static let preview: Self = .init(
        color: .gray.opacity(0.2)
    )
}
