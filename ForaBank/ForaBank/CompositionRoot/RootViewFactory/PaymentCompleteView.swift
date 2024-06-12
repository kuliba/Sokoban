//
//  PaymentCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.06.2024.
//

import SwiftUI

struct PaymentCompleteView: View {
    
    let state: State
    let goToMain: () -> Void
    
    var body: some View {
        
        switch state {
        case let .failure(fraud):
            FraudPaymentCompleteView(
                state: .init(
                    formattedAmount: fraud.formattedAmount,
                    hasExpired: fraud.hasExpired,
                    icon: .init("waiting")
                ),
                action: goToMain,
                config: .iFora
            )
            
        case let .success(report):
            TransactionCompleteView(
                state: .init(
                    details: report.details,
                    status: .completed
                ),
                goToMain: goToMain,
                config: .iFora
            )
        }
    }
}

extension PaymentCompleteView {
    
    typealias State = Result<Report, Fraud>

    struct Report {
        
        let status: DocumentStatus
        let detailID: Int
        let details: Details?
        
        typealias Details = TransactionCompleteView.State.Details
    }
    
    struct Fraud: Equatable, Error {
        
        let formattedAmount: String
        let hasExpired: Bool
    }
}

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

extension TransactionCompleteViewConfig {
    
    static let iFora: Self = .init(
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
        )
    )
}
