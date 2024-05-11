//
//  ComposedOperatorsViewFactory+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

extension ComposedOperatorsViewFactory
where SearchView == Text,
      LastPaymentView == Text,
      OperatorView == Text,
      FooterView == Text {
    
    static var preview: Self {
        
        return .init(
            makeLastPaymentView: { .init("LastPayment View: \($0)") },
            makeOperatorView: { .init("Operator View: \($0)") },
            makeFooterView: { .init("Footer View: \($0)") },
            makeSearchView: { .init("Search View: \($0)") }
        )
    }
}
