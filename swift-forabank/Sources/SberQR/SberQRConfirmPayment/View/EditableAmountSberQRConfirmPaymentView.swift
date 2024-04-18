//
//  EditableAmountSberQRConfirmPaymentView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import PaymentComponents
import SwiftUI

struct EditableAmountSberQRConfirmPaymentView: View {
    
    typealias State = EditableAmount<PaymentComponents.Info>
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
            PaymentComponents.AmountView(
                amount: state.amount,
                event: { event(.editAmount($0)) },
                pay: pay,
                currencySymbol: state.currencySymbol,
                config: config.amount
            )
        }
    }

    private func feed() -> some View {
        
        Group {
            
            PaymentComponents.ProductSelectView(
                state: state.productSelect,
                event: { event(.productSelect($0)) },
                config: config.productSelect
            ) {
                PaymentComponents.ProductCardView(
                    productCard: .init(product: $0),
                    config: config.productSelect.card.productCardConfig,
                    isSelected: state.productSelect.selected?.id == $0.id
                )
            }

            Group {
                
                PaymentComponents.InfoView(
                    info: state.brandName,
                    config: config.info
                )
                
                PaymentComponents.InfoView(
                    info: state.recipientBank,
                    config: config.info
                )
            }
            .padding(.default)
        }
    }
}

private extension EditableAmount<PaymentComponents.Info> {
    
    var currencySymbol: String {
        
        #warning("move to state as stored property + inject dictionary or define at call site")
        return "₽"
    }
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
            config: .preview
        )
    }
}
