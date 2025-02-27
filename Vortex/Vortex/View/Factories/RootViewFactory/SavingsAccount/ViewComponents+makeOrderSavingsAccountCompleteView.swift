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
            state: .init(formattedAmount: nil, merchantIcon: nil, status: complete.context.status.status),
            statusConfig: .orderSavingsAccount
        ) {
            HStack {
                RxWrapperView(model: complete.document) { state, _ in
                    
                    makeDocumentButtonViewWithShareButton(state: state)
                }
                
                RxWrapperView(model: complete.details) { state, _ in
                    
                    makeDetailsButton(state: state)
                }
            }
        } details: {
            EmptyView()
        } footer: {
            heroButton(title: "На главный", action: goToMain)
        }
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
        }
    }
}
