//
//  UtilityServicePaymentFlowState.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import ForaTools

#warning("replace with `Stack`")
// typealias UtilityServicePaymentFlowState = Stack<UtilityServicePaymentFlowDestination>
typealias UtilityServicePaymentFlowState = UtilityServicePaymentFlowDestination?

enum UtilityServicePaymentFlowDestination {
    
    case services
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
