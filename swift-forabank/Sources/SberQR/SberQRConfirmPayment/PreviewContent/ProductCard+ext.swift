//
//  ProductCard+ext.swift
//  
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SwiftUI

extension ProductCard {
    
    static let preview: Self = .init(
        data: .init(
            balanceFormatted: "123 456 ₽",
            number: "7891",
            type: "Platinum"
        ),
        look: .init(
            background: .svg(""),
            backgroundColor: .black.opacity(0.7),
            cardIcon: .svg(""),
            logo: .svg(""),
            mainCardMark: .svg(""),
            paymentSystemLogo: .svg("")
        )
    )
    
    static let preview2: Self = .init(
        data: .init(
            balanceFormatted: "123 456 ₽",
            number: "7891",
            type: "Gold"
        ),
        look: .init(
            background: .svg(""),
            backgroundColor: .orange.opacity(0.2),
            cardIcon: .svg(""),
            logo: .svg(""),
            mainCardMark: .svg(""),
            paymentSystemLogo: .svg("")
        )
    )
}
