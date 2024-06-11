//
//  PaymentCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.06.2024.
//

import SwiftUI

struct PaymentCompleteView: View {
    
    let result: AnywayTransactionStatus.TransactionResult
    let goToMain: () -> Void
    
    var body: some View {
        switch result {
        case let .failure(terminated):
            terminatedView(terminated)
            
        case let .success(report):
            content(.init(describing: report))
        }
    }
}

private extension PaymentCompleteView {
    
    @ViewBuilder
    func terminatedView(
        _ terminated: AnywayTransactionStatus.Terminated
    ) -> some View {
        
        switch terminated {
        case let .fraud(fraud):
            content(.init(describing: fraud))
            
        case .transactionFailure:
            // is handled by alert = bad model
            EmptyView()
            
        case .updatePaymentFailure:
            // is handled by alert = bad model
            EmptyView()
        }
    }
    
    func content(
        _ content: String
    ) -> some View {
        
        VStack(spacing: 32) {
            
            Text("TBD: Payment Complete View")
                .font(.headline)
            
            Text(String(describing: content))
                .foregroundColor(.secondary)
                .font(.footnote)
                .frame(maxHeight: .infinity)
            
            Divider()
            
            Button(
                "go to Main",
                action: goToMain
            )
        }
        .padding()
    }
}

extension FraudPaymentCompleteViewConfig {
    
    static let iFora: Self = .init(
        amountConfig: .init(
            textFont: .textH1Sb24322(),
            textColor: .textSecondary
        ),
        icon: .init("waiting"),
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
