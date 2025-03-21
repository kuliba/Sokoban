//
//  ViewComponents+makeOrderSavingsAccountCompleteView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import RxViewModel
import SwiftUI
import PaymentCompletionUI
import UIPrimitives

extension ViewComponents {
    
    @inlinable
    func makeOrderSavingsAccountCompleteView(
        asyncWait: ProcessingFlag,
        _ complete: OpenSavingsAccountCompleteDomain.Complete,
        action: @escaping () -> Void
    ) -> some View {
       
        let needAsyncWait: Bool = complete.context.status.status == .inflight && asyncWait.isActive
        let title: String = .savingsAccountTitle(needAsyncWait, complete.context.formattedAmount != nil)
        let subtitle: String? = needAsyncWait ? .processingSubtitle : nil

        let config: PaymentCompletionConfig = .orderSavingsAccount(title: title, subtitle: subtitle)
        
        return makePaymentCompletionLayoutView(
            state: complete.context.state(needAsyncWait),
            statusConfig: config,
            buttons: { makeButtons(needAsyncWait, complete) },
            details: { EmptyView() },
            footer: {
                heroButton(title: "На главный") {
                    action()
                    goToMain()
                }
            }
        )
    }

    @ViewBuilder
    func makeButtons(
        _ needAsyncWait: Bool,
        _ complete: OpenSavingsAccountCompleteDomain.Complete
    ) -> some View {
        
        switch (needAsyncWait, complete.context.status.status) {
        case (true, _):
            RxWrapperView(model: complete.details) { state, _ in
                
                makeDetailsButton(state: state)
            }
            
        case (false, .completed):
            HStack {
                RxWrapperView(model: complete.document) { state, _ in
                    
                    makeDocumentButtonViewWithShareButton(state: state)
                }
                
                RxWrapperView(model: complete.details) { state, _ in
                    
                    makeDetailsButton(state: state)
                }
            }
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func makeDetailsButton(
        state: OperationDetailSADomain.State
    )  -> some View {
        
        switch state {
        case let .completed(details):
            WithFullScreenCoverView {
                circleButton(image: .ic24Info, title: "Детали", action: $0)
            } sheet: {
                saTransactionDetails(details: details, dismiss: $0)
            }
            
        case .failure, .pending:
            EmptyView()
            
        case .loading:
            circleButtonPlaceholder()
        }
    }
    
    @inlinable
    func saTransactionDetails(
        details: any TransactionDetailsProviding<[DetailsCell]>,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        saDetailsView(details: details.transactionDetails)
            .navigationBarWithClose(
                title: "Детали операции",
                dismiss: dismiss
            )
    }

    @inlinable
    func saDetailsView(
        details: [DetailsCell]
    ) -> some View {
        
        DetailsView(
            detailsCells: details,
            config: .iVortex,
            detailsCellView: detailsCellView
        )
    }
    
    @inlinable
    @ViewBuilder
    func makeDocumentButtonViewWithShareButton(
        state: DocumentButtonDomain.State
    ) -> some View {
        
        switch state {
        case let .completed(document):
            WithSheetView {
                circleButton(image: .ic24File, title: "Документ", action: $0)
            } sheet: {
                PrintFormView(viewModel: .init(pdfDocument: document, dismissAction: $0))
            }
            
        case .failure, .pending:
            EmptyView()
            
        case .loading:
            circleButtonPlaceholder()
        }
    }
    
    @ViewBuilder
    func makeDetailsButton(
        state: OperationDetailDomain.State
    )  -> some View {
        
        switch state.extendedDetails {
            
        case let .completed(details):
            
            WithFullScreenCoverView {
                circleButton(image: .ic24Info, title: "Детали", action: $0)
            } sheet: {
                c2gTransactionDetails(details: details, dismiss: $0)
            }
            
        case .failure, .pending:
            EmptyView()
            
        case .loading:
            circleButtonPlaceholder()
        }
    }
}

extension OpenSavingsAccountCompleteDomain.Complete.Context.Status {
    
    var status: PaymentCompletion.Status {
        
        switch self {
        case .completed:
            return .completed
        case .inflight:
            return .inflight
        case .rejected:
            return .rejected
        case let .fraud(fraud):
            switch fraud {
            case .cancelled:
                return .fraud(.cancelled)
            case .expired:
                return .fraud(.expired)
            }
        case .suspend:
            return .suspend
        }
    }
}

extension String {
    
    static let processingTitle: Self = "Платеж успешно принят в обработку"
    static let processingSubtitle: Self =  "Баланс обновится после\nобработки операции"
}

private extension String {
    
    static let titleWithTopUp: Self = "Накопительный счет открыт\nи пополнен на сумму"
    static let titleWithOutTopUp: Self = "Накопительный счет открыт"
    
    static func savingsAccountTitle(
        _ processing: Bool,
        _ withTopUp: Bool
    ) -> Self {
        processing
        ? processingTitle
        : {
            withTopUp ? titleWithTopUp : titleWithOutTopUp
        }()
    }
}

private extension OpenSavingsAccountCompleteDomain.Complete.Context.Status {
    
    func newStatus(
        _ asyncWait: Bool
    ) -> PaymentCompletion.Status {
        
        switch self.status {
        case .inflight:
            asyncWait ? .completed : .inflight
            
        default: self.status
        }
    }
}

private extension OpenSavingsAccountCompleteDomain.Complete.Context {
    
    func state(
        _ needAsyncWait: Bool
    ) -> PaymentCompletion {
        
        .init(
            formattedAmount: status == .rejected ? nil : formattedAmount,
            merchantIcon: nil,
            status: status.newStatus(needAsyncWait)
        )
    }
}
