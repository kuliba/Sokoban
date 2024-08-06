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
    
    typealias State = PaymentCompleteState
    typealias Factory = PaymentCompleteViewFactory
    typealias Config = PaymentCompletionConfig
}

private extension PaymentCompleteView {
    
    var transactionCompleteState: TransactionCompleteState {
        
        switch state.result {
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
            formattedAmount: state.formattedAmount,
            merchantIcon: nil,
            status: paymentCompletionStatus
        )
    }
    
    private var paymentCompletionStatus: PaymentCompletion.Status {
        
        switch state.result {
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

extension PaymentCompleteState {
    
    static let fraudCancelled: Self = failure(.init(hasExpired: false))
    static let fraudExpired: Self = failure(.init(hasExpired: true))
    static let completed: Self = success(.completed)
    static let inflight: Self = success(.inflight)
    static let rejected: Self = success(.rejected)
    
    private static func failure(
        _ fraud: Fraud
    ) -> Self {
        
        return preview(.failure(fraud))
    }
    
    private static func success(
        _ report: Report
    ) -> Self {
        
        return preview(.success(report))
    }
    
    private static func preview(
        _ result: Result<Report, Fraud>
    ) -> Self {
        
        return .init(formattedAmount: "1,000 ₽", result: result)
    }
}

extension PaymentCompleteState.Report {
    
    static let completed: Self = .preview(.completed)
    static let inflight: Self = .preview(.inflight)
    static let rejected: Self = .preview(.rejected)
    
    private static func preview(
        detailID: Int = 1,
        details: Details? = nil,
        _ status: DocumentStatus
    ) -> Self {
        
        return .init(
            detailID: detailID,
            details: details,
            status: status
        )
    }
}

extension PaymentCompleteViewFactory {
    
    static let preview: Self = .init(
        makeDetailButton: { _ in .init(details: .init(logo: nil, cells: [])) },
        makeDocumentButton: { _ in .init(getDocument: { _ in }) },
        makeTemplateButton: {
            
            return .init(
                viewModel: .init(
                    model: .emptyMock,
                    operation: nil,
                    operationDetail: .stub()
                )
            )
        }
    )
}
#endif
