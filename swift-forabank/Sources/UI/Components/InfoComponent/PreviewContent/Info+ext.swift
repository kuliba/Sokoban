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
        value: "220 ₽",
        title: "Сумма",
        image: .init(.init("dollarsign.circle.fill"))
    )
    
    static let brandName: Self = .init(
        id: .brandName,
        value: "сббол енот_QR",
        title: "Получатель",
        image: .init(.init("house"))
    )
    
    static let recipientBank: Self = .init(
        id: .recipientBank,
        value: "Сбербанк",
        title: "Банк получателя",
        image: .init(.init("building.columns"))
    )
    
    private static func just(
        _ systemName: String
    ) -> AnyPublisher<Image, Never> {
        
        Just(.init(systemName: "building.columns")).eraseToAnyPublisher()
    }
}
