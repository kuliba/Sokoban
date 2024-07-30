//
//  TransactionCompleteViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

extension TransactionCompleteViewConfig {
    
    static let iFora: Self = .init(
        amountConfig: .init(
            textFont: .textH1Sb24322(),
            textColor: .textSecondary
        ),
        icons: .init(
            completed: .init(
                image: .init("OkOperators"),
                color: .systemColorActive
            ),
            inflight: .init(
                image: .init("waiting"),
                color: .systemColorWarning
            ),
            rejected: .init(
                image: .ic48Close,
                color: .init(hex: "E3011B")
            ),
            fraud: .init(
                image: .init("waiting"),
                color: .systemColorWarning
            )
        ),
        message: "Оплата прошла успешно",
        messageConfig: .init(
            textFont: .textH3Sb18240(),
            textColor: .textSecondary
        ),
        logoHeight: 40
    )
}
