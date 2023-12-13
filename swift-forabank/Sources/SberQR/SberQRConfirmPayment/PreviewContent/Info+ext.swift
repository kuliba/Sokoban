//
//  Info+ext.swift
//  
//
//  Created by Igor Malyarov on 13.12.2023.
//

extension Info {
    
    static func preview(
        info: GetSberQRDataResponse.Parameter.Info
    ) -> Self {
        
        .init(
            id: info.id,
            value: info.value,
            title: info.title,
            image: .init(systemName: "sparkles.tv")
        )
    }
    
    static let amount: Self = .init(
        id: .amount,
        value: "220 ₽",
        title: "Сумма",
        image: .init(systemName: "dollarsign.circle.fill")
    )
    
    static let brandName: Self = .init(
        id: .brandName,
        value: "сббол енот_QR",
        title: "Получатель",
        image: .init(systemName: "house")
    )
    
    static let recipientBank: Self = .init(
        id: .recipientBank,
        value: "Сбербанк",
        title: "Банк получателя",
        image: .init(systemName: "building.columns")
    )
}
