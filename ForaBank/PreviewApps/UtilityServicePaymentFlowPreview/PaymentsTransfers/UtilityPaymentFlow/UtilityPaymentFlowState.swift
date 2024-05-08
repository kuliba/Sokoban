//
//  UtilityPaymentFlowState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import ForaTools

struct UtilityPaymentFlowState<UtilityPrepaymentViewModel, PaymentViewModel> {
    
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
    #warning("make generic?")
    enum Destination {
        
        case operatorFailure(OperatorFailureFlowState)
        case payByInstructions
        case payment(UtilityServicePaymentFlowState<PaymentViewModel>)
        case servicePicker(ServicePickerFlowState)
    }
}

extension UtilityPaymentFlowState.Destination {
    #warning("extract subtypes to get rid of generics where they are not needed")
    struct OperatorFailureFlowState {
        
        let content: Content
        var destination: Destination?
        
        init(
            content: Content,
            destination: Destination? = nil
        ) {
            self.content = content
            self.destination = destination
        }
        
        typealias Content = Operator
    }
    
    struct ServicePickerFlowState {
        
        let content: Content
        var destination: Destination?
        var alert: Alert?
        
        init(
            content: Content,
            destination: Destination? = nil,
            alert: Alert? = nil
        ) {
            self.content = content
            self.destination = destination
            self.alert = alert
        }
    }
}

extension UtilityPaymentFlowState.Destination.OperatorFailureFlowState {
    
    enum Destination {
        
        case payByInstructions
    }
}

extension UtilityPaymentFlowState.Destination.ServicePickerFlowState {
    
    struct Content: Equatable {
        
        let services: MultiElementArray<UtilityService>
        let `operator`: Operator
    }
    
    enum Alert {
        
        case serviceFailure(ServiceFailure)
    }
    
    enum Destination {
        
        case payment(UtilityServicePaymentFlowState<PaymentViewModel>)
    }
}

extension UtilityPaymentFlowState.Destination.ServicePickerFlowState.Destination {
    
    typealias StartPaymentResponse = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentSuccess.StartPaymentResponse
}
