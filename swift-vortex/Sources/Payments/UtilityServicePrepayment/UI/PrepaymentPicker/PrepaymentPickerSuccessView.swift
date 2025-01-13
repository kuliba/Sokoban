//
//  PrepaymentPickerSuccessView.swift
//
//
//  Created by Дмитрий Савушкин on 08.02.2024.
//

import SwiftUI
import UtilityServicePrepaymentDomain

public struct PrepaymentPickerSuccessView<LastPayment, Operator, FooterView, LastPaymentView, OperatorView, SearchView>: View
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
        
        VStack(spacing: 16) {
            
            factory.makeSearchView()
                .padding(.horizontal, 16)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    if state.searchText.isEmpty {
                     
                        _lastPaymentsView(state.lastPayments)
                    }
                    
                    _operatorsView(state.operators)
                    factory.makeFooterView(false)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
    }
}

public extension PrepaymentPickerSuccessView {
    
    typealias State = PrepaymentPickerSuccess<LastPayment, Operator>
    typealias Event = PrepaymentPickerEvent<Operator>
    
    typealias Factory = PrepaymentPickerFactory<LastPayment, Operator, SearchView, LastPaymentView, OperatorView, FooterView>
}

private extension PrepaymentPickerSuccessView {
    
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
            
            LazyVStack(alignment: .leading, spacing: 13) {
                
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

struct PrepaymentPickerSuccessView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PrepaymentPickerSuccessView(
            state: .preview,
            event: { print($0) },
            factory: .preview
        )
    }
}
