//
//  Info+ext.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import SwiftUI

public extension Info {
    
    static let amount: Self = .init(
        id: .amount,
        title: "Сумма",
        value: "220 ₽",
        style: .expanded
    )
    
    static let brandName: Self = .init(
        id: .brandName,
        title: "Получатель",
        value: "сббол енот_QR",
        style: .expanded
    )
    
    static let recipientBank: Self = .init(
        id: .recipientBank,
        title: "Банк получателя",
        value: "Сбербанк",
        style: .expanded
    )
}
