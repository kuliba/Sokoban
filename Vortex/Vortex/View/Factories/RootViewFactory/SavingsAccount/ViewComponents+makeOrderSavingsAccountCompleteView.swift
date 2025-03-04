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
        _ complete: OpenSavingsAccountCompleteDomain.Complete,
        action: @escaping () -> Void
    ) -> some View {
       
        makePaymentCompletionLayoutView(
            state: .init(formattedAmount: complete.context.formattedAmount, merchantIcon: nil, status: complete.context.status.status),
            statusConfig: .orderSavingsAccount(
                title: complete.context.formattedAmount != nil
                ? "Накопительный счет открыт\nи пополнен на сумму"
                : "Накопительный счет открыт")
        ) {
            makeButtons(complete)
        } details: {
            EmptyView()
        } footer: {
            heroButton(title: "На главный") {
                action()
                goToMain()
            }
        }
    }
    
    @ViewBuilder
    func makeButtons(
        _ complete: OpenSavingsAccountCompleteDomain.Complete
    ) -> some View {
        
        if complete.context.status.status != .suspend {
            HStack {
                RxWrapperView(model: complete.document) { state, _ in
                    
                    makeDocumentButtonViewWithShareButton(state: state)
                }
                
                RxWrapperView(model: complete.details) { state, _ in
                    
                    makeDetailsButton(state: state)
                }
            }
        } else {
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
                circleButton(image: .ic24File, title: "Детали", action: $0)
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
