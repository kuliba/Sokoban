//
//  LastPaymentLabelConfig+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

extension LastPaymentLabelConfig {
    
    static let preview: Self = .init(
        amount: .init(
            textFont: .title3,
            textColor: .black
        ),
        title: .init(
            textFont: .body,
            textColor: .gray
        )
    )
}
