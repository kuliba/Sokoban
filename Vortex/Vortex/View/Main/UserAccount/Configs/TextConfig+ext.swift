//
//  TextConfig+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.02.2024.
//

import UIPrimitives

extension TextConfig {
    
    static let secondary: Self = .init(
        textFont: .textH4M16240(),
        textColor: .textSecondary
    )
    
    static let placeholder: Self = .init(
        textFont: .textBodyMR14180(),
        textColor: .textPlaceholder
    )
}
