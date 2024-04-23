//
//  UtilityPaymentOperatorPicker.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct UtilityPaymentOperatorPicker<Icon>: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        UtilityPaymentOperatorPickerLayoutView(
            state: state,
            factory: .init(
                footerView: footerView,
                lastPaymentsView: lastPaymentsView,
                operatorsView: operatorsView
            )
        )
    }
    
    private func footerView(
        _ state: Bool
    ) -> some View {
        
        UtilityPaymentOperatorPickerFooterView(
            state: state,
            event: {
                switch $0 {
                case .addCompany:
                    event(.addCompany)
                    
                case .payByInstructions:
                    event(.payByInstructions)
                }
            }
        )
    }
    
    private func lastPaymentsView(
        lastPayments: [State.LastPayment]
    ) -> some View {
        
        HStack {
            
            ForEach(lastPayments, content: lastPaymentView)
        }
    }

    private func lastPaymentView(
        lastPayment: State.LastPayment
    ) -> some View {
        
        Button(String(describing: lastPayment).prefix(6)) {
            
            event(.select(.lastPayment(lastPayment)))
        }
    }

    private func operatorsView(
        operators: [State.Operator]
    ) -> some View {
        
        List {
            
            ForEach(operators, content: operatorView)
        }
    }

    private func operatorView(
        `operator`: State.Operator
    ) -> some View {
        
        Button(String(describing: `operator`).prefix(32)) {
            
            event(.select(.`operator`(`operator`)))
        }
    }
}

extension UtilityPaymentOperatorPicker {
    
    typealias State = UtilityPaymentOperatorPickerState<Icon>
    typealias Event = UtilityPaymentOperatorPickerEvent<Icon>
    typealias Config = UtilityPaymentOperatorPickerConfig
}

//#Preview {
//    UtilityPaymentOperatorPicker()
//}
