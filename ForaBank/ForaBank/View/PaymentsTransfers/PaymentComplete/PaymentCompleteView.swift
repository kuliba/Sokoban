//
//  PaymentCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.06.2024.
//

import SwiftUI
import PaymentCompletionUI

struct PaymentCompleteView: View {
    
    let state: State
    let goToMain: () -> Void
    let `repeat`: () -> Void
    let factory: Factory
    let config: Config
    
    var body: some View {
        
        TransactionCompleteView(
            state: transactionCompleteState,
            goToMain: goToMain,
            repeat: `repeat`,
            factory: factory
        ) {
            PaymentCompletionStatusView(
                state: paymentCompletionState,
                config: config
            )
        }
    }
}

extension PaymentCompleteView {
    
    typealias State = Result<Report, Fraud>
    
    struct Report {
        
        let detailID: Int
        let details: Details?
        let status: DocumentStatus
        
        typealias Details = TransactionCompleteState.Details
    }
    
    struct Fraud: Equatable, Error {
        
        let formattedAmount: String
        let hasExpired: Bool
    }
    
    typealias Factory = PaymentCompleteViewFactory
    typealias Config = PaymentCompletionConfig
}

private extension PaymentCompleteView {
    
    var transactionCompleteState: TransactionCompleteState {
        
        switch state {
        case .failure:
            return .init(details: nil, documentID: nil, status: .fraud)
            
        case let .success(report):
            return .init(
                details: report.details,
                documentID: .init(report.detailID),
                status: {
                    
                    switch report.status {
                    case .completed: return .completed
                    case .inflight:  return .inflight
                    case .rejected:  return .rejected
                    }
                }()
            )
        }
    }
    
    var paymentCompletionState: PaymentCompletion {
        
        return .init(
            formattedAmount: formattedAmount,
            merchantIcon: nil,
            status: paymentCompletionStatus
        )
    }
    
    private var formattedAmount: String {
        
        switch state {
        case let .failure(fraud):
            return fraud.formattedAmount
            
        case let .success(report):
            return "report"
        }
    }
    
    private var paymentCompletionStatus: PaymentCompletion.Status {
        
        switch state {
        case let .failure(fraud):
            return .fraud(fraud.hasExpired ? .expired : .cancelled)
            
        case let .success(report):
            switch report.status {
            case .completed: return .completed
            case .inflight:  return .inflight
            case .rejected:  return .rejected
            }
        }
    }
}

#if DEBUG
struct PaymentCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            paymentCompleteView(state: .fraudCancelled)
                .previewDisplayName("fraud: cancelled")
            paymentCompleteView(state: .fraudExpired)
                .previewDisplayName("fraud: expired")
            paymentCompleteView(state: .completed)
                .previewDisplayName("completed")
            paymentCompleteView(state: .inflight)
                .previewDisplayName("inflight")
            paymentCompleteView(state: .rejected)
                .previewDisplayName("rejected")
        }
    }
    
    private static func paymentCompleteView(
        state: PaymentCompleteView.State
    ) -> some View {
        
        PaymentCompleteView(
            state: state,
            goToMain: {},
            repeat: {},
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
        detailID: Int = 1,
        details: Details? = nil,
        _ status: DocumentStatus
    ) -> Self {
        
        return .init(detailID: detailID, details: details, status: status)
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
