//
//  UtilityServicePaymentFlowEvent.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

enum UtilityServicePaymentFlowEvent<Icon> {
    
    case resetDestination
    case selectUtilityService(UtilityService<Icon>)
}

extension UtilityServicePaymentFlowEvent: Equatable where Icon: Equatable {}
