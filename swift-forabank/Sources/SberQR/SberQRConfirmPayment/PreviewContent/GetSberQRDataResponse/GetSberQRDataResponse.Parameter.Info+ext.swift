//
//  GetSberQRDataResponse.Parameter.Info+ext.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

extension GetSberQRDataResponse.Parameter.Info {
    
    static let amount: Self = .init(
        id: .amount,
        value: "220 ₽",
        title: "Сумма",
        icon: .init(
            type: .local,
            value: "ic24IconMessage"
        )
    )
    
    static let brandName: Self = .init(
        id: .brandName,
        value: "сббол енот_QR",
        title: "Получатель",
        icon: .init(
            type: .remote,
            value: "b6e5b5b8673544184896724799e50384"
        )
    )
    
    static let recipientBank: Self = .init(
        id: .recipientBank,
        value: "Сбербанк",
        title: "Банк получателя",
        icon: .init(
            type: .remote,
            value: "c37971b7264d55c3c467d2127ed600aa"
        )
    )
}
