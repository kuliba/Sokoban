//
//  RootViewFactory+makePaymentsTransfersTransfersView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension RootViewFactory {
    
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
        
        RxWrapperView(model: transfers.flow) {
            
            PaymentsTransfersPersonalTransfersFlowView(
                state: $0,
                event: $1,
                contentView: {
                    
                    ComposedPaymentsTransfersTransfersContentView(
                        content: transfers.content
                    )
                },
                viewFactory: personalTransfersFlowViewFactory
            )
        }
    }
}

// MARK: - View Factories

private extension RootViewFactory {
    
    var personalTransfersFlowViewFactory: PaymentsTransfersPersonalTransfersFlowViewFactory {
        
        return .init(
            makeContactsView: components.makeContactsView,
            makePaymentsMeToMeView: components.makePaymentsMeToMeView,
            makePaymentsView: components.makePaymentsView,
            makePaymentsSuccessView: components.makePaymentsSuccessView
        )
    }
}
