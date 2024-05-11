//
//  ComposedOperatorsViewFactory.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

public struct ComposedOperatorsViewFactory<SearchView, LastPaymentView, OperatorView, FooterView>
where SearchView: View,
      LastPaymentView: View,
      OperatorView: View,
      FooterView: View {
    
    let lastPaymentView: (LatestPayment) -> LastPaymentView
    let operatorView: (Operator) -> OperatorView
    let footerView: () -> FooterView
    let searchView: () -> SearchView
    
    public init(
        lastPaymentView: @escaping (LatestPayment) -> LastPaymentView,
        operatorView: @escaping (Operator) -> OperatorView,
        footerView: @escaping () -> FooterView,
        searchView: @escaping () -> SearchView
    ) {
        self.lastPaymentView = lastPaymentView
        self.operatorView = operatorView
        self.footerView = footerView
        self.searchView = searchView
    }
}
