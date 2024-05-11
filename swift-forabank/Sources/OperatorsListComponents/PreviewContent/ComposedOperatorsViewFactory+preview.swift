//
//  ComposedOperatorsViewFactory+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

extension ComposedOperatorsViewFactory
where FooterView == Text,
      LastPaymentView == Text,
      OperatorView == Text,
      SearchView == Text {
    
    static var preview: Self {
        
        return .init(
            makeFooterView: { .init("Footer View: \($0)") },
            makeLastPaymentView: { .init("LastPayment View: \($0)") },
            makeOperatorView: { .init("Operator View: \($0)") },
            makeSearchView: { .init("Search View") }
        )
    }
}
