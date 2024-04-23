//
//  UtilityServicePaymentFlowEvent.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

enum UtilityServicePaymentFlowEvent: Equatable {
    
    case resetDestination
    case selectUtilityService(UtilityService)
}
