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
        statuses: .init(
            completed: .init(
                icon: .init(
                    image: .init("OkOperators"),
                    color: .systemColorActive
                ),
                message: "Успешный перевод",
                messageConfig: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .textSecondary
                )
            ),
            inflight: .init(
                icon: .init(
                    image: .init("waiting"),
                    color: .systemColorWarning
                ),
                message: "Операция в обработке!",
                messageConfig: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .textSecondary
                )
            ),
            rejected: .init(
                icon: .init(
                    image: .ic48Close,
                    color: .init(hex: "E3011B")
                ),
                message: "Операция неуспешна",
                messageConfig: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .textSecondary
                )
            ),
            fraud: .init(
                icon: .init(
                    image: .init("waiting"),
                    color: .systemColorWarning
                ),
                message: "Перевод отменен!",
                messageConfig: .init(
                    textFont: .textH3Sb18240(),
                    textColor: .textRed
                )
            )
        ),
        logoHeight: 40
    )
}
