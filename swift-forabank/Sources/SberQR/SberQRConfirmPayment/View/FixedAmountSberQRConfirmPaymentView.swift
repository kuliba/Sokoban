//
//  FixedAmountSberQRConfirmPaymentView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct FixedAmountSberQRConfirmPaymentView: View {
    
    typealias State = SberQRConfirmPaymentStateOf<Info>.FixedAmount
    typealias Event = SberQRConfirmPaymentEvent.FixedAmount
    
    let state: State
    let event: (Event) -> Void
    let pay: () -> Void
    let config: Config
    
    var body: some View {
        
        FeedWithBottomView(
            feed: feed,
            backgroundColor: config.background.color
        ) {
            ButtonView(
                button: state.bottom,
                pay: pay
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
                info: state.amount,
                config: config.info
            )
            
            InfoView(
                info: state.recipientBank,
                config: config.info
            )
        }
    }
}

// MARK: - Previews

struct FixedAmountSberQRConfirmPaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        sberQRConfirmPaymentView(.preview)
    }
    
    private static func sberQRConfirmPaymentView(
        _ state: FixedAmountSberQRConfirmPaymentView.State
    ) -> some View {
        
        FixedAmountSberQRConfirmPaymentView(
            state: state,
            event: { _ in },
            pay: {},
            config: .default
        )
    }
}
