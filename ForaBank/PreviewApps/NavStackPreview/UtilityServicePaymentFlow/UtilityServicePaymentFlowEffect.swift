//
//  UtilityServicePaymentFlowEffect.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

enum UtilityServicePaymentFlowEffect<Icon> {
    
    case selectUtilityServiceOperator(Operator)
}

extension UtilityServicePaymentFlowEffect {
    
    typealias Operator = UtilityPaymentOperatorPickerState<Icon>.Operator
}
