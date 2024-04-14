//
//  AnywayPaymentFooterView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import PaymentComponents
import SwiftUI

struct AnywayPaymentFooterView: View {
    
    let state: AnywayPaymentFooter
    let event: (AnywayPaymentFooterEvent) -> Void
    let config: AmountConfig
    
    var body: some View {
        
        if let core = state.core {
            PaymentComponents.AmountView(
                amount: .init(
                    value: core.value, 
                    isEnabled: state.isEnabled
                ),
                event: { event(.edit($0)) },
                pay: { event(.pay) },
                currencySymbol: core.currency,
                config: config
            )
        } else {
            Text("TBD: `Continue` button")
        }
    }
}

private extension PaymentComponents.Amount {
    
    init(value: Decimal, isEnabled: Bool) {
        
        self.init(
            title: "Сумма платежа",
            value: value,
            button: .init(
                title: "Продолжить",
                isEnabled: isEnabled
            )
        )
    }
}

struct AnywayPaymentFooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            footer(core: nil, isEnabled: false)
            footer(core: nil, isEnabled: true)
            footer(core: .init(value: 12_345.67, currency: "RUB"))
        }
    }
    
    private static func footer(
        core: AnywayPaymentFooter.Core? = nil,
        isEnabled: Bool = true
    ) -> some View {
        
        AnywayPaymentFooterView(
            state: .init(core: core, isEnabled: isEnabled),
            event: { _ in },
            config: .preview
        )
    }
}
