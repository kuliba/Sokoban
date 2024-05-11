//
//  ComposedOperatorsViewFactory.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct ComposedOperatorsViewFactory<LastPayment, Operator, SearchView, LastPaymentView, OperatorView, FooterView>
where SearchView: View,
      LastPaymentView: View,
      OperatorView: View,
      FooterView: View {
    
    let makeLastPaymentView: MakeLastPaymentView
    let makeOperatorView: MakeOperatorView
    let makeFooterView: MakeFooterView
    let makeSearchView: MakeSearchView
    
    public init(
        makeLastPaymentView: @escaping MakeLastPaymentView,
        makeOperatorView: @escaping MakeOperatorView,
        makeFooterView: @escaping MakeFooterView,
        makeSearchView: @escaping MakeSearchView
    ) {
        self.makeLastPaymentView = makeLastPaymentView
        self.makeOperatorView = makeOperatorView
        self.makeFooterView = makeFooterView
        self.makeSearchView = makeSearchView
    }
}

public extension ComposedOperatorsViewFactory {
    
    typealias MakeLastPaymentView = (LastPayment) -> LastPaymentView
    typealias MakeOperatorView = (Operator) -> OperatorView
    typealias MakeFooterView = (Bool) -> FooterView
    typealias MakeSearchView = (String) -> SearchView
}
