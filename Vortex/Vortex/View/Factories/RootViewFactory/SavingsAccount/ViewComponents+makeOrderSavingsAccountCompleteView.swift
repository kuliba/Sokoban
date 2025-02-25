//
//  ViewComponents+makeOrderSavingsAccountCompleteView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import RxViewModel
import SwiftUI
import PaymentCompletionUI

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
                    
                    makeDocumentButtonView(state: state)
                    
                }
                
//                RxWrapperView(model: complete.details) { state, _ in
//                    
//                    makeDetaView(state: state)
//                    
//                }
            }
        } details: {
            EmptyView()
        } footer: {
            heroButton(action: goToMain)
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
