//
//  UtilityPaymentOperatorPickerLayoutView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct UtilityPaymentOperatorPickerLayoutView<Icon, FooterView, LastPaymentsView, OperatorsView>: View
where FooterView: View,
      LastPaymentsView: View,
      OperatorsView: View {
    
    let state: State
    let factory: Factory
    
    var body: some View {
        
        if state.operators.isEmpty {
            errorView()
        } else {
            listView()
        }
    }
    
    private func errorView() -> some View {
        
        VStack {
            
            factory.footerView(false)
        }
    }
    
    private func listView() -> some View {
        
        VStack {
            
            factory.lastPaymentsView(state.lastPayments)
            factory.operatorsView(state.operators)
            factory.footerView(true)
        }
    }
}

extension UtilityPaymentOperatorPickerLayoutView {
    
    typealias State = UtilityPaymentOperatorPickerState<Icon>
    typealias Factory = UtilityPaymentOperatorPickerFactory<Icon, FooterView, LastPaymentsView, OperatorsView>
}

//#Preview {
//    UtilityPaymentOperatorPickerLayoutView()
//}
