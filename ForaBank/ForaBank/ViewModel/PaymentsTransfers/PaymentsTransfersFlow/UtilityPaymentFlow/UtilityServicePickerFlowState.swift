//
//  UtilityServicePickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.05.2024.
//

import ForaTools

struct UtilityServicePickerFlowState<Operator, Service, PaymentViewModel> {
    
    var alert: Alert?
    let content: Content
    var destination: Destination?
}

extension UtilityServicePickerFlowState {
    
    typealias Alert = ServiceFailureAlert
    
    struct Content {
        
        let services: MultiElementArray<Service>
        let `operator`: Operator
    }
    
    enum Destination {
        
        case payment(Payment)
    }
}

extension UtilityServicePickerFlowState.Destination {
    
    typealias Payment = UtilityServicePaymentFlowState<PaymentViewModel>
}

extension UtilityServicePickerFlowState.Content: Equatable where Operator: Equatable, Service: Equatable {}
