//
//  PrepaymentPickerFactory+preview.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SwiftUI

extension PrepaymentPickerFactory
where FooterView == Text,
      LastPaymentView == Text,
      OperatorView == Text,
      SearchView == Text {
    
    static var preview: Self {
        
        return .init(
            makeFooterView: { _ in .init("Footer View") },
            makeLastPaymentView: { _ in .init("LastPayment View") },
            makeOperatorView: { _ in .init("Operator View") },
            makeSearchView: { .init("Search View") }
        )
    }
}
