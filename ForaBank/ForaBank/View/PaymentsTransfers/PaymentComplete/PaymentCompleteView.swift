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
    let config: Config
    
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
    typealias Config = PaymentCompleteViewConfig
}

private extension PaymentCompleteView {
    
    func completeView(
        _ fraud: Fraud
    ) -> some View {
        
        completeView(
            status: .fraud,
            content: { fraudContent(fraud, config: config.fraud) }
        )
    }
    
    func completeView(
        _ report: Report
    ) -> some View {
        
        completeView(
            details: report.details,
            documentID: .init(report.detailID),
            status: .completed,
            content: { reportContent(report, config: config.transaction) }
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
            config: config.transaction,
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

#if DEBUG
struct PaymentCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            paymentCompleteView(state: .fraudCancelled)
            paymentCompleteView(state: .fraudExpired)
        }
    }
    
    private static func paymentCompleteView(
        state: PaymentCompleteView.State
    ) -> some View {
        
        PaymentCompleteView(
            state: state,
            goToMain: {},
            factory: .preview,
            config: .iFora
        )
    }
}

extension PaymentCompleteView.State {
    
    static let fraudCancelled: Self = .failure(.init(
        formattedAmount: "1,000 ₽",
        hasExpired: false
    ))
    
    static let fraudExpired: Self = .failure(.init(
        formattedAmount: "1,000 ₽",
        hasExpired: true
    ))
    
    static let completed: Self = .success(.completed)
    static let inflight: Self = .success(.inflight)
    static let rejected: Self = .success(.rejected)
}

extension PaymentCompleteView.Report {
    
    static let completed: Self = .preview(.completed)
    static let inflight: Self = .preview(.inflight)
    static let rejected: Self = .preview(.rejected)
    
    private static func preview(
        _ status: DocumentStatus,
        detailID: Int = 1,
        details: Details? = nil
    ) -> Self {
        
        return .init(status: status, detailID: detailID, details: details)
    }
}

extension PaymentCompleteViewFactory {
    
    static let preview: Self = .init(
        makeDetailButton: { _ in .init(details: .init(logo: nil, cells: [])) },
        makeDocumentButton: { _ in .init(getDocument: { _ in }) },
        makeTemplateButton: { return .init(viewModel: .init(model: .emptyMock, operation: nil, operationDetail: .stub()))
        }
    )
}
#endif
