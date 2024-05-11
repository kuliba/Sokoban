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
    
    let lastPaymentView: (LatestPayment) -> LastPaymentView
    let operatorView: (Operator) -> OperatorView
    let footerView: () -> FooterView
    let searchView: () -> SearchView
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        lastPaymentView: @escaping (LatestPayment) -> LastPaymentView,
        operatorView: @escaping (Operator) -> OperatorView,
        footerView: @escaping () -> FooterView,
        searchView: @escaping () -> SearchView
    ) {
        self.state = state
        self.event = event
        self.lastPaymentView = lastPaymentView
        self.operatorView = operatorView
        self.footerView = footerView
        self.searchView = searchView
    }
}

public extension ComposedOperatorsView {
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            searchView()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    _lastPaymentsView(state.latestPayments)
                    _operatorsView(state.operators)
                    
                    footerView()
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
}

private extension ComposedOperatorsView {
    
    @ViewBuilder
    func _lastPaymentsView(
        _ lastPayments: [LatestPayment]?
    ) -> some View {
        
        if let lastPayments,
           !lastPayments.isEmpty {
            
            ScrollView(.horizontal) {
                
                LazyHStack {
                    
                    ForEach(lastPayments, content: lastPaymentView)
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
        
        operatorView(`operator`)
            .onAppear { event(.utility(.didScrollTo(`operator`.id))) }
    }
}

struct ComposedOperatorsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ComposedOperatorsView(
            state: .init(operators: [], latestPayments: []),
            event: { print($0) },
            lastPaymentView: { _ in  EmptyView() },
            operatorView: { _ in  EmptyView() },
            footerView: EmptyView.init,
            searchView: EmptyView.init
        )
    }
}
