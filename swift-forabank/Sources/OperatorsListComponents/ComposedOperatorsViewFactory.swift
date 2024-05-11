//
//  ComposedOperatorsViewFactory.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct ComposedOperatorsViewFactory<LastPayment, Operator, FooterView, LastPaymentView, OperatorView, SearchView>
where FooterView: View,
      LastPaymentView: View,
      OperatorView: View,
      SearchView: View {
    
    let makeFooterView: MakeFooterView
    let makeLastPaymentView: MakeLastPaymentView
    let makeOperatorView: MakeOperatorView
    let makeSearchView: MakeSearchView
    
    public init(
        makeFooterView: @escaping MakeFooterView,
        makeLastPaymentView: @escaping MakeLastPaymentView,
        makeOperatorView: @escaping MakeOperatorView,
        makeSearchView: @escaping MakeSearchView
    ) {
        self.makeFooterView = makeFooterView
        self.makeLastPaymentView = makeLastPaymentView
        self.makeOperatorView = makeOperatorView
        self.makeSearchView = makeSearchView
    }
}

public extension ComposedOperatorsViewFactory {
    
    typealias MakeFooterView = (Bool) -> FooterView
    typealias MakeLastPaymentView = (LastPayment) -> LastPaymentView
    typealias MakeOperatorView = (Operator) -> OperatorView
    typealias MakeSearchView = (String) -> SearchView
}
