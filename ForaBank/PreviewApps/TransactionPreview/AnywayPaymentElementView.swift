//
//  AnywayPaymentElementView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import SwiftUI
import AnywayPaymentDomain

struct AnywayPaymentElementView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        Text("TBD: AnywayPaymentElementView")
            .foregroundColor(.red)
    }
}

extension AnywayPaymentElementView {
    
    typealias State = AnywayPayment.Element
    typealias Event = AnywayPaymentEvent
}

#Preview {
    AnywayPaymentElementView(
        state: .parameter(.stringInput),
        event: { print($0) }
    )
}
