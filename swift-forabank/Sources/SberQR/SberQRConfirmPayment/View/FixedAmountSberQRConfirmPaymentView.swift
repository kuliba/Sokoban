//
//  FixedAmountSberQRConfirmPaymentView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import PaymentComponents
import SwiftUI

struct FixedAmountSberQRConfirmPaymentView: View {
    
    typealias State = FixedAmount<Info>
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
                state: state.button,
                event: pay,
                config: config.button
            )
            .padding(.leading, 16)
            .padding(.trailing, 15)
        }
    }
    
    private func feed() -> some View {
        
        Group {
            
            ProductSelectView(
                state: state.productSelect,
                event: { event(.productSelect($0)) },
                config: config.productSelect
            ) {
                ProductCardView(
                    productCard: .init(product: $0),
                    config: config.productSelect.card.productCardConfig
                )
            }
            
            Group {
                
                InfoView(
                    info: state.brandName,
                    style: .expanded,
                    config: config.info
                )
                
                InfoView(
                    info: state.amount,
                    style: .expanded,
                    config: config.info
                )
                
                InfoView(
                    info: state.recipientBank,
                    style: .expanded,
                    config: config.info
                )
            }
            .padding(.default)
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
            config: .preview
        )
    }
}
