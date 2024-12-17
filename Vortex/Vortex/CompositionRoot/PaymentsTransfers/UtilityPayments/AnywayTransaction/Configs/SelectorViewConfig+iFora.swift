//
//  SelectorViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SelectorComponent

extension SelectorViewConfig {
    
    static func iFora(title: String) -> Self {
        
        return .init(
            title: .init(
                text: title,
                config: .init(
                    textFont: .textBodyMR14180(),
                    textColor: .textPlaceholder
                )
            ),
            search: .init(
                textFont: .textH4M16240(),
                textColor: .textSecondary
            )
        )
    }
}
