//
//  EditableAmountSberQRConfirmPaymentView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct EditableAmountSberQRConfirmPaymentView: View {
    
    typealias State = SberQRConfirmPaymentStateOf<Info>.EditableAmount
    typealias Event = SberQRConfirmPaymentEvent.EditableAmount
    
    let state: State
    let event: (Event) -> Void
    let pay: () -> Void
    let config: Config

    var body: some View {
        
        FeedWithBottomView(
            feed: feed,
            backgroundColor: config.background.color
        ) {
            AmountView(
                amount: state.bottom,
                event: { event(.editAmount($0)) },
                pay: pay,
                currencySymbol: state.currencySymbol,
                config: config.amount
            )
        }
    }

    private func feed() -> some View {
        
        Group {
            
            // HeaderView(header: state.header)

            ProductSelectView(
                state: state.productSelect,
                event: { event(.productSelect($0)) },
                config: config.productSelect
            )

            InfoView(
                info: state.brandName,
                config: config.info
            )
            
            InfoView(
                info: state.recipientBank,
                config: config.info
            )
            
            // DataStringView(data: state.currency)
        }
    }
}

private extension SberQRConfirmPaymentStateOf<Info>.EditableAmount {
    
    var currencySymbol: String { "₽" }
}

// MARK: - Previews

struct EditableAmountSberQRConfirmPaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        sberQRConfirmPaymentView(.preview)
    }
    
    private static func sberQRConfirmPaymentView(
        _ state: EditableAmountSberQRConfirmPaymentView.State
    ) -> some View {
        
        EditableAmountSberQRConfirmPaymentView(
            state: state,
            event: { _ in },
            pay: {},
            config: .default
        )
    }
}
