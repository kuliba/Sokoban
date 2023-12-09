//
//  EditableAmountSberQRConfirmPaymentView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct EditableAmountSberQRConfirmPaymentView: View {
    
    let state: SberQRConfirmPaymentState.EditableAmount
    let event: (SberQRConfirmPaymentEvent.EditableAmount) -> Void
    let pay: () -> Void
    
    var body: some View {
        
        FeedWithBottomView(feed: feed) {
            
            AmountView(
                amount: state.bottom,
                event: { event(.editAmount($0)) },
                pay: pay
            )
        }
    }

    private func feed() -> some View {
        
        Group {
            
            HeaderView(header: state.header)
            ProductSelectView(
                state: state.productSelect,
                event: { event(.productSelect($0)) }
            )
            InfoView(info: state.brandName)
            InfoView(info: state.recipientBank)
            DataStringView(data: state.currency)
        }
    }
}

// MARK: - Previews

struct EditableAmountSberQRConfirmPaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        sberQRConfirmPaymentView(.preview)
    }
    
    private static func sberQRConfirmPaymentView(
        _ state: SberQRConfirmPaymentState.EditableAmount
    ) -> some View {
        
        EditableAmountSberQRConfirmPaymentView(
            state: state,
            event: { _ in },
            pay: {}
        )
    }
}
