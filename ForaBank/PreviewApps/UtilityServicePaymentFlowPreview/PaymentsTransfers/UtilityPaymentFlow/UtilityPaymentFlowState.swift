//
//  UtilityPaymentFlowState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import ForaTools

struct UtilityPaymentFlowState {
    
    let viewModel: UtilityPrepaymentViewModel
    var destination: Destination?
    var alert: Alert?
    
    init(
        viewModel: UtilityPrepaymentViewModel,
        destination: Destination? = nil,
        alert: Alert? = nil
    ) {
        self.viewModel = viewModel
        self.destination = destination
        self.alert = alert
    }
}

extension UtilityPaymentFlowState {
    
    enum Alert {
        
        case serviceFailure(ServiceFailure)
    }
    
    enum Destination {
        
        case operatorFailure(OperatorFailure)
        case payByInstructions
        case payment(PaymentFlowState)
        case servicePicker(ServicePickerState)
    }
}

extension UtilityPaymentFlowState.Destination {
    
    struct OperatorFailure {
        
        let `operator`: Operator
        var destination: Destination?
        
        init(
            `operator`: Operator,
            destination: Destination? = nil
        ) {
            self.operator = `operator`
            self.destination = destination
        }
    }
    
    struct ServicePickerState {
        
        let services: MultiElementArray<UtilityService>
        let `operator`: Operator
        var destination: Destination?
        var alert: Alert?
        
        init(
            services: MultiElementArray<UtilityService>,
            `operator`: Operator,
            destination: Destination? = nil,
            alert: Alert? = nil
        ) {
            self.services = services
            self.operator = `operator`
            self.destination = destination
            self.alert = alert
        }
    }
    
    typealias StartPaymentResponse = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentSuccess.StartPaymentResponse
}

extension UtilityPaymentFlowState.Destination.OperatorFailure {
    
    enum Destination {
        
        case payByInstructions
    }
}

extension UtilityPaymentFlowState.Destination.ServicePickerState {
    
    enum Alert {
        
        case serviceFailure(ServiceFailure)
    }
    
    enum Destination {
        
        case payment(PaymentFlowState)
    }
}

extension UtilityPaymentFlowState.Destination.ServicePickerState.Destination {
    
    typealias StartPaymentResponse = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentSuccess.StartPaymentResponse
}
