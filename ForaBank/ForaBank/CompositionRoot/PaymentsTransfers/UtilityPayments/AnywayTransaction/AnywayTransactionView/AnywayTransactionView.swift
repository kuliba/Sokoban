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
            
            ScrollViewReader { proxy in
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 32) {
                        
                        ForEach(
                            state.payment.payment.elements,
                            content: factory.makeElementView
                        )
                        
                    }
                    .padding()
                }
                .onAppear { scrollToLast(proxy) }
                .onChange(of: state.payment.payment.elements.map(\.id)) {
                    
                    scrollToLastItem(proxy, iDs: $0)
                }
            }
            
            factory.makeFooterView(state, { event($0.transactionEvent) })
        }
    }
    
    private func scrollToLast(
        _ proxy: ScrollViewProxy
    ) {
        if let lastElement = state.payment.payment.elements.last {
            
            withAnimation {
                
                proxy.scrollTo(lastElement.id, anchor: .bottom)
            }
        }
    }
    
    private func scrollToLastItem(
        _ proxy: ScrollViewProxy,
        iDs: [Element.ID]
    ) {
        if let last = iDs.last {
            
            withAnimation {
                
                proxy.scrollTo(last, anchor: .bottom)
            }
        }
    }
    
    typealias Element = AnywayPaymentDomain.AnywayPayment.Element
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
