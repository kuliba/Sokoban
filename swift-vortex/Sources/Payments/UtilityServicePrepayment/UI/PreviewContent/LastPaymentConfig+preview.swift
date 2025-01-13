//
//  LastPaymentLabelConfig+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

extension LastPaymentLabelConfig {
    
    static let preview: Self = .init(
        amount: .init(textFont: .title3, textColor: .black),
        frameHeight: 80,
        iconSize: 40,
        title: .init(textFont: .body, textColor: .gray)
    )
}
