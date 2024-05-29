//
//  AnywayPaymentFooterView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import SwiftUI

struct AnywayPaymentFooterView: View {
    
    let state: AnywayPaymentFooter
    let event: (AnywayPaymentFooterEvent) -> Void
    let config: AnywayPaymentFooterConfig
    
    var body: some View {
        
        if let core = state.core {
            amountView(state.buttonTitle, core, state.isEnabled, config.amountConfig)
        } else {
            continueButton(state.buttonTitle, config.buttonConfig)
        }
    }
    
    private func amountView(
        _ buttonTitle: String,
        _ core: AnywayPaymentFooter.Core,
        _ isEnabled: Bool,
        _ config: AmountConfig
    ) -> some View {
        
        PaymentComponents.AmountView(
            amount: .init(
                buttonTitle: buttonTitle,
                value: core.value,
                isEnabled: isEnabled
            ),
            event: { event(.edit($0)) },
            pay: { event(.continue) },
            currencySymbol: core.currency,
            config: config
        )
    }
    
    private func continueButton(
        _ title: String,
        _ config: ButtonConfig
    ) -> some View {
        
        PaymentComponents.ButtonView(
            state: .init(
                id: .buttonPay,
                value: title,
                color: .red,
                action: .pay,
                placement: .bottom
            ),
            event: { event(.continue) },
            config: config
        )
        .padding(.horizontal)
        .disabled(!state.isEnabled)
    }
}

private extension PaymentComponents.Amount {
    
    init(
        buttonTitle: String,
        value: Decimal,
        isEnabled: Bool
    ) {
        self.init(
            title: buttonTitle,
            value: value,
            button: .init(
                title: buttonTitle,
                isEnabled: isEnabled
            )
        )
    }
}

struct AnywayPaymentFooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            Group {
                
                footer(core: nil, isEnabled: false)
                footer(buttonTitle: "Pay!", core: nil, isEnabled: true)
            }
            .padding(.horizontal)
            
            footer(
                buttonTitle: "Оплатить",
                core: .init(value: 12_345.67, currency: "₽")
            )
        }
    }
    
    private static func footer(
        buttonTitle: String = "Продолжить",
        core: AnywayPaymentFooter.Core? = nil,
        isEnabled: Bool = true
    ) -> some View {
        
        AnywayPaymentFooterView(
            state: .init(
                buttonTitle: buttonTitle,
                core: core,
                isEnabled: isEnabled
            ),
            event: { _ in },
            config: .preview
        )
    }
}
