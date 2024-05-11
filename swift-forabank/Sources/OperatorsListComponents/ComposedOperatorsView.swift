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
            
            factory.makeSearchView(state.searchText)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    _lastPaymentsView(state.lastPayments)
                    _operatorsView(state.operators)
                    
#warning("remove `onAppear` - that is a flow event")
                    factory.makeFooterView(state.operators.isEmpty)
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
    
    typealias State = ComposedOperatorsState
    typealias Event = ComposedOperatorsEvent
    
    typealias Factory = ComposedOperatorsViewFactory<SearchView, LastPaymentView, OperatorView, FooterView>
}

private extension ComposedOperatorsView {
    
    @ViewBuilder
    func _lastPaymentsView(
        _ lastPayments: [LastPayment]
    ) -> some View {
        
        if !lastPayments.isEmpty {
            
            ScrollView(.horizontal) {
                
                LazyHStack {
                    
                    ForEach(lastPayments, content: factory.makeLastPaymentView)
                }
            }
        }
    }
    
    @ViewBuilder
    func _operatorsView(
        _ operators: [Operator]
    ) -> some View {
        
        if !operators.isEmpty {
            
            LazyVStack(alignment: .leading, spacing: 8) {
                
                ForEach(operators, content: _operatorView)
            }
        }
    }
    
    func _operatorView(
        operator: Operator
    ) -> some View {
        
        factory.makeOperatorView(`operator`)
            .onAppear { event(.utility(.didScrollTo(`operator`.id))) }
    }
}

struct ComposedOperatorsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ComposedOperatorsView(
            state: .preview,
            event: { print($0) },
            factory: .preview
        )
    }
}
