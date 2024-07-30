//
//  FraudPaymentCompleteViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

extension FraudPaymentCompleteViewConfig {
    
    static let iFora: Self = .init(
        amountConfig: .init(
            textFont: .textH1Sb24322(),
            textColor: .textSecondary
        ),
        iconColor: .systemColorWarning,
        message: "Перевод отменен!",
        messageConfig: .init(
            textFont: .textH4M16240(),
            textColor: .systemColorError
        ),
        reason: "Время на подтверждение\nперевода вышло",
        reasonConfig: .init(
            textFont: .textH3Sb18240(),
            textColor: .textSecondary
        )
    )
}
