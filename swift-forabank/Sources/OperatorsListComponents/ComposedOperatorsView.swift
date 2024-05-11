//
//  ComposedOperatorsView.swift
//
//
//  Created by Дмитрий Савушкин on 08.02.2024.
//

import SwiftUI

public struct ComposedOperatorsView<SearchView, LastPaymentView, OperatorView, FooterView>: View
where SearchView: View,
      LastPaymentView: View,
      OperatorView: View,
      FooterView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
}

public extension ComposedOperatorsView {
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            factory.searchView()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    _lastPaymentsView(state.latestPayments)
                    _operatorsView(state.operators)
                    
#warning("remove `onAppear` - that is a flow event")
                    factory.footerView()
                        .onAppear { event(.utility(.initiate)) }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

public extension ComposedOperatorsView {
    
    typealias LastPayment = LatestPayment
    typealias State = ComposedOperatorsState
    typealias Event = ComposedOperatorsEvent
    
    typealias Factory = ComposedOperatorsViewFactory<SearchView, LastPaymentView, OperatorView, FooterView>
}

private extension ComposedOperatorsView {
    
    @ViewBuilder
    func _lastPaymentsView(
        _ lastPayments: [LastPayment]?
    ) -> some View {
        
        if let lastPayments,
           !lastPayments.isEmpty {
            
            ScrollView(.horizontal) {
                
                LazyHStack {
                    
                    ForEach(lastPayments, content: factory.lastPaymentView)
                }
            }
        }
    }
    
    @ViewBuilder
    func _operatorsView(
        _ operators: [Operator]?
    ) -> some View {
        
        if let operators = state.operators,
           !operators.isEmpty {
            
            LazyVStack(alignment: .leading, spacing: 8) {
                
                ForEach(operators, content: _operatorView)
            }
        }
    }
    
    func _operatorView(
        operator: Operator
    ) -> some View {
        
        factory.operatorView(`operator`)
            .onAppear { event(.utility(.didScrollTo(`operator`.id))) }
    }
}

struct ComposedOperatorsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ComposedOperatorsView(
            state: .init(operators: [], latestPayments: []),
            event: { print($0) },
            factory: .preview
        )
    }
}

private extension ComposedOperatorsViewFactory
where SearchView == EmptyView,
      LastPaymentView == Text,
      OperatorView == Text,
      FooterView == EmptyView {
    
    static let preview: Self = .init(
        lastPaymentView: { .init("LastPaymentView: \($0)") },
        operatorView: { .init("OperatorView: \($0)") },
        footerView: EmptyView.init,
        searchView: EmptyView.init
    )
}
