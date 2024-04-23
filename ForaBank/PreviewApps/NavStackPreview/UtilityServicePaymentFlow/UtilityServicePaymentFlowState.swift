//
//  UtilityServicePaymentFlowState.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import ForaTools

#warning("replace with `Stack`")
// typealias UtilityServicePaymentFlowState = Stack<UtilityServicePaymentFlowDestination>
typealias UtilityServicePaymentFlowState<Icon> = UtilityServicePaymentFlowDestination<Icon>?

enum UtilityServicePaymentFlowDestination<Icon> {
    
    case services(UtilityServicePickerState<Icon>)
}

extension UtilityServicePaymentFlowDestination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .services:
            return .services
        }
    }
    
    enum ID {
        
        case services
    }
}
