//
//  FixedAmountSberQRConfirmPaymentView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct FixedAmountSberQRConfirmPaymentView: View {
    
    let state: SberQRConfirmPaymentState.FixedAmount
    let event: (SberQRConfirmPaymentEvent.FixedAmount) -> Void
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
                config: config.productSelectViewConfig
            )
            
            InfoView(
                info: state.brandName,
                config: config.infoConfig
            )
            
            InfoView(
                info: state.amount,
                config: config.infoConfig
            )
            
            InfoView(
                info: state.recipientBank,
                config: config.infoConfig
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
        _ state: SberQRConfirmPaymentState.FixedAmount
    ) -> some View {
        
        FixedAmountSberQRConfirmPaymentView(
            state: state,
            event: { _ in },
            pay: {},
            config: .default
        )
    }
}
