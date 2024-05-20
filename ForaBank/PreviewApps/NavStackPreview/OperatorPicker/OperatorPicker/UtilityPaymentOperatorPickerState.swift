//
//  UtilityPaymentOperatorPickerState.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

struct UtilityPaymentOperatorPickerState<Icon> {
    
    let lastPayments: [LastPayment]
    let operators: [Operator]
}

extension UtilityPaymentOperatorPickerState {
    
    struct LastPayment: Identifiable {
        
        let id: String
        let icon: Icon
    }
    
    struct Operator: Identifiable {
        
        let id: String
        let icon: Icon
    }
}

extension UtilityPaymentOperatorPickerState.LastPayment: Equatable where Icon: Equatable {}
extension UtilityPaymentOperatorPickerState.Operator: Equatable where Icon: Equatable {}
