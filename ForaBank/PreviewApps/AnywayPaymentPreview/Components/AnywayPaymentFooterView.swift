//
//  AnywayPaymentFooterView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentFooterView: View {
    
    let elements: [AnywayPayment.Element]
    let event: (AnywayPaymentEvent) -> Void
    // let event: () -> Void
    
    var body: some View {
        
        if let amount = elements.amount {
            AmountView(
                amount: amount.value,
                currency: amount.currency,
                event: event
            )
        } else {
            Text("TBD: `Continue` button")
        }
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    var amount: (value: Decimal, currency: String)? {
        
        guard case let .widget(.core(core)) = self[id: .widgetID(.core)]
        else { return nil }
        
        return (core.amount, core.currency.rawValue)
    }
}

struct AnywayPaymentFooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentFooterView(elements: .preview, event: { _ in })
    }
}
