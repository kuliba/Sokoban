//
//  UtilityPaymentOperatorPickerLayoutFactory.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct UtilityPaymentOperatorPickerLayoutFactory<Icon, FooterView, LastPaymentsView, OperatorsView>
where FooterView: View,
      LastPaymentsView: View,
      OperatorsView: View {
    
    let footerView: MakeFooterView
    let lastPaymentsView: MakeLastPaymentView
    let operatorsView: MakeOperatorView
}

extension UtilityPaymentOperatorPickerLayoutFactory {
    
    typealias MakeFooterView = (Bool) -> FooterView
    
    typealias LastPayment = UtilityPaymentOperatorPickerState<Icon>.LastPayment
    typealias MakeLastPaymentView = ([LastPayment]) -> LastPaymentsView
    
    typealias Operator = UtilityPaymentOperatorPickerState<Icon>.Operator
    typealias MakeOperatorView = ([Operator]) -> OperatorsView
}
