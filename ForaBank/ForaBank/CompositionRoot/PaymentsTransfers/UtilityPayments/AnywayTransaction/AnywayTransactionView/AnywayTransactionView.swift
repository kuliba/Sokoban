//
//  AnywayTransactionView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import SwiftUI
import UIPrimitives

struct AnywayTransactionView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            paymentView(elements: elements)
            factory.makeFooterView(state) { event($0.transactionEvent) }
        }
    }
}

extension AnywayTransactionView {
    
    typealias State = CachedTransactionState
    typealias Event = AnywayTransactionEvent
    typealias Factory = AnywayPaymentFactory<IconView>
    typealias IconView = UIPrimitives.AsyncImage
}

private extension AnywayTransactionView {
    
    var elements: [Element] { state.context.payment.models }
    
    private func paymentView(
        elements: [Element]
    ) -> some View {
        
        ScrollViewReader { proxy in
            
            ScrollView(showsIndicators: false, content: scrollContent)
                .onAppear { scrollToLast(of: elements, proxy) }
                .onChange(of: elements.map(\.id).last) {
                    
                    scrollToLastItem(withID: $0, proxy)
                }
        }
    }
    
    private func scrollContent() -> some View {
        
        VStack(spacing: 16) {
            
            ForEach(elements) { factory.makeElementView($0) }
        }
        .padding()
    }
    
    private func scrollToLast(
        of elements: [Element],
        _ proxy: ScrollViewProxy
    ) {
        scrollToLastItem(withID: elements.last?.id, proxy)
    }
    
    private func scrollToLastItem(
        withID id: Element.ID?,
        _ proxy: ScrollViewProxy
    ) {
        if let id {
            
            withAnimation {
                
                proxy.scrollTo(id, anchor: .bottom)
            }
        }
    }
    
    typealias Element = CachedAnywayPayment<AnywayElementModel>.IdentifiedModel
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
