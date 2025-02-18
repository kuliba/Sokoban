//
//  PaymentCompleteView.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.06.2024.
//

import Combine
import PaymentCompletionUI
import PaymentComponents
import SwiftUI

struct PaymentCompleteView: View {
    
    let state: State
    let goToMain: () -> Void
    let `repeat`: () -> Void
    let factory: Factory
    let config: Config
    
    var body: some View {
        
        VStack {
            
            paymentCompletionStatusView()
            Spacer()
            transactionCompleteView()
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension PaymentCompleteView {
    
    typealias State = PaymentCompleteState
    typealias Factory = PaymentCompleteViewFactory
    typealias Config = PaymentCompletionConfig
}

private extension PaymentCompleteView {
    
    func paymentCompletionStatusView() -> some View {
        
        PaymentCompletionStatusView(
            state: state.paymentCompletionState,
            makeIconView: factory.makeIconView,
            config: config
        )
    }
    
    func transactionCompleteView() -> some View {
        
        VStack(spacing: 56) {
            
            buttons(state: state.transactionCompleteState)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            VStack(spacing: 8) {
                
                // repeatButton(state: state.transactionCompleteState)
                
                PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
            }
        }
    }
    
    @ViewBuilder
    func buttons(
        state: TransactionCompleteState
    ) -> some View {
        
        switch state.status {
        case .completed:
            HStack {
                
                state.operationDetail.map(factory.makeTemplateButtonWrapperView)
                state.documentID.map(factory.makeDocumentButton)
                state.details.map(factory.makeDetailButton)
            }
            
        case .inflight:
            HStack {
                
                factory.makeTemplateButton()
                state.details.map(factory.makeDetailButton)
            }
            
        case .rejected, .fraud:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func repeatButton(
        state: TransactionCompleteState
    ) -> some View {
        
        if state.status == .rejected {
            
            Button("TBD: Repeat Button", action: `repeat`)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color.buttonSecondary)
                )
        }
    }
}

private extension PaymentCompleteState {
    
    var transactionCompleteState: TransactionCompleteState {
        
        switch result {
        case .failure:
            return .init(details: nil, operationDetail: nil, documentID: nil, status: .fraud)
            
        case let .success(report):
            return .init(
                details: report.details,
                operationDetail: report.operationDetail,
                documentID: (.init(report.detailID), report.printFormType),
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
            merchantIcon: merchantIcon,
            status: paymentCompletionStatus
        )
    }
    
    private var paymentCompletionStatus: PaymentCompletion.Status {
        
        switch result {
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
            paymentCompleteView(state: .completedWithDetails)
                .previewDisplayName("completed with Details")
            paymentCompleteView(state: .completedWithDocumentID)
                .previewDisplayName("completed with DocumentID")
            paymentCompleteView(state: .completedWithDetailsAndDocumentID)
                .previewDisplayName("completed with Details and DocumentID")
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
            config: .payment
        )
    }
}

extension PaymentCompleteState {
    
    static let fraudCancelled: Self = failure(.init(hasExpired: false))
    static let fraudExpired: Self = failure(.init(hasExpired: true))
    static let completed: Self = success(.completed)
    static let completedWithDetails: Self = success(.completedWithDetails)
    static let completedWithDocumentID: Self = success(.completedWithDocumentID)
    static let completedWithDetailsAndDocumentID: Self = success(.completedWithDetailsAndDocumentID)
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
        
        return .init(formattedAmount: "1,000 ₽", merchantIcon: nil, result: result)
    }
}

extension PaymentCompleteState.Report {
    
    static let completed: Self = .preview(.completed)
    static let completedWithDetails: Self = .preview(details: .empty, .completed)
    static let completedWithDocumentID: Self = .preview(detailID: 1, .completed)
    static let completedWithDetailsAndDocumentID: Self = .preview(detailID: 1, details: .empty, .completed)
    static let inflight: Self = .preview(.inflight)
    static let rejected: Self = .preview(.rejected)
    
    private static func preview(
        detailID: Int = 1,
        details: TransactionDetailButton.Details? = nil,
        operationDetail: OperationDetailData? = nil,
        printFormType: String = "abc",
        _ status: DocumentStatus
    ) -> Self {
        
        return .init(
            detailID: detailID,
            details: details,
            operationDetail: operationDetail,
            printFormType: printFormType,
            status: status
        )
    }
}

private extension TransactionDetailButton.Details {
    
    static let empty: Self = .init(logo: nil, cells: [])
}

extension PaymentCompleteViewFactory {
    
    static let preview: Self = .init(
        makeDetailButton: { _ in .init(details: .init(logo: nil, cells: [])) },
        makeDocumentButton: { _,_  in .init(getDocument: { _ in }) },
        makeIconView: {
            
            return .init(
                image: .init(systemName: $0 ?? "pencil.and.outline"),
                publisher: Just(.init(systemName: $0 ?? "tray.full.fill")).delay(for: .seconds(1), scheduler: DispatchQueue.main).eraseToAnyPublisher()
            )
        },
        makeTemplateButton: {
            
            return .init(
                viewModel: .init(
                    model: .emptyMock,
                    operation: nil,
                    operationDetail: .stub()
                )
            )
        },
        makeTemplateButtonWrapperView: {
            
            .init(viewModel: .init(model: .emptyMock, operation: nil, operationDetail: $0))
        }
    )
}
#endif
