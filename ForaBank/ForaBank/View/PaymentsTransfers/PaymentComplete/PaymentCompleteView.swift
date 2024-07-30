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
    let factory: Factory

    var body: some View {
        
        switch state {
        case let .failure(fraud):
            completeView(fraud)
            
        case let .success(report):
            completeView(report)
        }
    }
}

extension PaymentCompleteView {
    
    typealias State = Result<Report, Fraud>

    struct Report {
        
        let status: DocumentStatus
        let detailID: Int
        let details: Details?
        
        typealias Details = TransactionCompleteState.Details
    }
    
    struct Fraud: Equatable, Error {
        
        let formattedAmount: String
        let hasExpired: Bool
    }
    
    typealias Factory = PaymentCompleteViewFactory
}

private extension PaymentCompleteView {
    
    func completeView(
        _ fraud: Fraud
    ) -> some View {
        
        completeView(
            status: .fraud,
            content: { fraudContent(fraud, config: .iFora) }
        )
    }
    
    func completeView(
        _ report: Report
    ) -> some View {
        
        completeView(
            details: report.details,
            documentID: .init(report.detailID),
            status: .completed,
            content: { reportContent(report, config: .iFora) }
        )
    }
    
    func completeView(
        details: TransactionCompleteState.Details? = nil,
        documentID: DocumentID? = nil,
        status: TransactionCompleteState.Status,
        content: @escaping () -> some View
    ) -> some View {
        
        TransactionCompleteView(
            state: .init(
                details: details,
                documentID: documentID,
                status: status
            ),
            goToMain: goToMain,
            config: .iFora,
            content: content,
            factory: factory
        )
    }
    
    func fraudContent(
        _ state: Fraud,
        config: FraudPaymentCompleteViewConfig
    ) -> some View {
        
        VStack(spacing: 24) {
            
            VStack(spacing: 12) {
                
                config.message.text(withConfig: config.messageConfig)
                
                if state.hasExpired {
                    
                    config.reason.text(withConfig: config.reasonConfig)
                        .multilineTextAlignment(.center)
                }
            }
            
            state.formattedAmount.text(withConfig: config.amountConfig)
        }
    }
    
    func reportContent(
        _ report: Report,
        config: TransactionCompleteViewConfig
    ) -> some View {
        
        VStack(spacing: 24) {
            
            config.message.text(withConfig: config.messageConfig)
            
            report.details?.logo.map {
                $0
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: config.logoHeight, height: config.logoHeight)
            }
        }
    }
}
