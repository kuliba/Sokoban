//
//  AnywayPaymentFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import SwiftUI

extension AnywayPaymentFactory
where IconView == Text {
    
    static var preview: Self {
        
        return .init(
            makeElementView: {
                
                return .init(
                    state: $0,
                    event: { print($0) },
                    factory: .preview,
                    config: .init(info: .preview)
                )
            },
            makeFooterView: { .init() }
        )
    }
}
