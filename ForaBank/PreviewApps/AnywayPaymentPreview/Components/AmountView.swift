//
//  AmountView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import SwiftUI

struct AmountView: View {
    
    let amount: Decimal
    let currency: String
    let event: (AnywayPaymentEvent) -> Void
    
    var body: some View {
        
        Text("TBD: amount view: " + String(describing: (amount, currency)))
    }
}

struct AmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AmountView(amount: 12_345.67, currency: "ZUB", event: { _ in })
    }
}
