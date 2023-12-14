//
//  Info+ext.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import SwiftUI

extension Info {
    
    public static func preview(
        info: GetSberQRDataResponse.Parameter.Info
    ) -> Self {
        
        .init(
            id: info.id,
            value: info.value,
            title: info.title,
            image: just("sparkles.tv")
        )
    }
    
    static let amount: Self = .init(
        id: .amount,
        value: "220 ₽",
        title: "Сумма",
        image: just("dollarsign.circle.fill")
    )
    
    static let brandName: Self = .init(
        id: .brandName,
        value: "сббол енот_QR",
        title: "Получатель",
        image: just("house")
    )
    
    static let recipientBank: Self = .init(
        id: .recipientBank,
        value: "Сбербанк",
        title: "Банк получателя",
        image: just("building.columns")
    )
    
    private static func just(
        _ systemName: String
    ) -> AnyPublisher<Image, Never> {
        
        Just(.init(systemName: "building.columns")).eraseToAnyPublisher()
    }
}
