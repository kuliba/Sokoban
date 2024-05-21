//
//  AnywayTransactionView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct AnywayTransactionView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 32) {
                
                Text(state.isValid ? "valid" : "invalid")
                    .foregroundColor(state.isValid ? .green : .red)
                    .font(.headline)
                
                Divider()
                
                Text("TBD: Payment UI")
                    .foregroundColor(.red)
                
            }
            .padding()
        }
    }
}

extension AnywayTransactionView {
    
    typealias State = AnywayTransactionState
    typealias Event = AnywayTransactionEvent
}

#Preview {
    AnywayTransactionView(state: .preview, event: { print($0) })
}
