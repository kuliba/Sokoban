//
//  RootViewFactory+makePaymentsTransfersTransfersView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @ViewBuilder
    func makePaymentsTransfersTransfersView(
        transfersPicker: PayHubUI.TransfersPicker
    ) -> some View {
        
        if let binder = transfersPicker.transfersBinder {
            
            makePaymentsTransfersTransfersView(transfers: binder)
            
        } else {
            
            Text("Unexpected transfersPicker type \(String(describing: transfersPicker))")
                .foregroundColor(.red)
        }
    }
    
    private func makePaymentsTransfersTransfersView(
        transfers: PaymentsTransfersPersonalTransfersDomain.Binder
    ) -> some View {
        
        RxWrapperView(model: transfers.flow) { state, event in
            
            PaymentsTransfersPersonalTransfersFlowView(
                state: state,
                event: event,
                contentView: {
                    
                    ComposedPaymentsTransfersTransfersContentView(
                        content: transfers.content
                    )
                    .disabled(state.isLoading)
                },
                viewFactory: personalTransfersFlowViewFactory
            )
        }
    }
}

// MARK: - View Factories

private extension ViewComponents {
    
    var personalTransfersFlowViewFactory: PaymentsTransfersPersonalTransfersFlowViewFactory {
        
        return .init(
            makeContactsView: makeContactsView,
            makePaymentsMeToMeView: makePaymentsMeToMeView,
            makePaymentsView: makePaymentsView,
            makePaymentsSuccessView: makePaymentsSuccessView
        )
    }
}
