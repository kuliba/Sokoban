//
//  UtilityServicePaymentFlowState.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import ForaTools

#warning("replace with `Stack`")
// typealias UtilityServicePaymentFlowState = Stack<UtilityServicePaymentFlowDestination>

struct UtilityServicePaymentFlowState<Icon> {
    
    #warning("this is BAD - a mix of flow state and domain state!")
    var operatorPickerState: OperatorPickerState
    var destination: Destination?
}

extension UtilityServicePaymentFlowState {
    
    enum Destination {
        
        case services(UtilityServicePickerState<Icon>)
    }
    
    typealias OperatorPickerState = UtilityPaymentOperatorPickerState<Icon>
}

extension UtilityServicePaymentFlowState.Destination: Identifiable {
    
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
