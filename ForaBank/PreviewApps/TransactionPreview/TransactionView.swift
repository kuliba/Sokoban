//
//  TransactionView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct TransactionView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        Text("TBD: TransactionView")
            .foregroundColor(.red)
    }
}

extension TransactionView {
    
    typealias State = TransactionState
    typealias Event = TransactionEvent
}

#Preview {
    TransactionView(state: .preview, event: { print($0) })
}
