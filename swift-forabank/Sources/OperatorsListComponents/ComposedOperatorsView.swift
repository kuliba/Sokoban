//
//  ComposedOperatorsView.swift
//
//
//  Created by Дмитрий Савушкин on 08.02.2024.
//

import SwiftUI

#warning("`Composed` does not fit well here")
public struct ComposedOperatorsView<LastPayment, Operator, FooterView, LastPaymentView, OperatorView, SearchView>: View
where LastPayment: Identifiable,
      Operator: Identifiable,
      FooterView: View,
      LastPaymentView: View,
      OperatorView: View,
      SearchView: View {
    
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
    
    public var body: some View {
        
        if state.operators.isEmpty {
            factory.makeFooterView(false)
        } else {
            list()
        }
    }
}

public extension ComposedOperatorsView {
    
    typealias State = ComposedOperatorsState<LastPayment, Operator>
    typealias Event = ComposedOperatorsEvent<Operator.ID>
    
    typealias Factory = ComposedOperatorsViewFactory<LastPayment, Operator, SearchView, LastPaymentView, OperatorView, FooterView>
}

private extension ComposedOperatorsView {
    
    func list() -> some View {
        
        VStack(spacing: 16) {
            
            factory.makeSearchView()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    _lastPaymentsView(state.lastPayments)
                    _operatorsView(state.operators)
                    
                    factory.makeFooterView(state.operators.isEmpty)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
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
            .onAppear { event(.didScrollTo(`operator`.id)) }
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
