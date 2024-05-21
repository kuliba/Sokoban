//
//  AnywayTransactionView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI
import AnywayPaymentDomain

struct AnywayTransactionView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 32) {
                
                Text(state.isValid ? "valid" : "invalid")
                    .foregroundColor(state.isValid ? .green : .red)
                    .font(.headline)
                
                Divider()
                
                ForEach(
                    state.payment.payment.elements,
                    content: factory.makeElementView
                )
                
            }
            .padding()
        }
    }
}

extension AnywayTransactionView {
    
    typealias State = AnywayTransactionState
    typealias Event = AnywayTransactionEvent
    typealias Factory = AnywayPaymentFactory
}

#Preview {
    AnywayTransactionView(state: .preview, event: { print($0) }, factory: .preview)
}
