//
//  AnywayTransactionView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import SwiftUI
import UIPrimitives

struct AnywayTransactionView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ForEach(
                        state.payment.payment.elements,
                        content: factory.makeElementView
                    )
                    
                }
                .padding()
            }
            
            factory.makeFooterView(state, { event($0.transactionEvent) })
        }
    }
}

extension AnywayTransactionView {
    
    typealias State = AnywayTransactionState
    typealias Event = AnywayTransactionEvent
    typealias Factory = AnywayPaymentFactory<IconView>
    typealias IconView = UIPrimitives.AsyncImage
}

// MARK: - Adapters

private extension AnywayPaymentFooterEvent {
    
    var transactionEvent: AnywayTransactionEvent {
        
        switch self {
        case .continue:
            return .continue
            
        case let .edit(decimal):
            return .payment(.widget(.amount(decimal)))
        }
    }
}
