//
//  UtilityServicePaymentFlowEvent.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

enum UtilityServicePaymentFlowEvent<Icon> {
    
    case resetDestination
    case selectUtilityService(Service)
    case selectUtilityServiceOperator(Operator)
}

extension UtilityServicePaymentFlowEvent{
    
    typealias Service = UtilityService<Icon>
    typealias Operator = UtilityPaymentOperatorPickerState<Icon>.Operator
}

extension UtilityServicePaymentFlowEvent: Equatable where Icon: Equatable {}
