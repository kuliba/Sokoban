//
//  UtilityPaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import ForaTools

struct UtilityPaymentFlowState<LastPayment, Operator, UtilityService, Content, PaymentViewModel> {
    
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

extension UtilityPaymentFlowState {
    
    typealias Alert = ServiceFailureAlert
    
    #warning("make generic?")
    enum Destination {
        
        case operatorFailure(OperatorFailure)
        case payByInstructions(PayByInstructionsViewModel)
        case payment(Payment)
        case servicePicker(UtilityServicePickerFlowState)
    }
}

extension UtilityPaymentFlowState.Destination {
    
    typealias OperatorFailure = SberOperatorFailureFlowState<Operator>
    typealias PayByInstructionsViewModel = PaymentsViewModel
    typealias Payment = UtilityServicePaymentFlowState<PaymentViewModel>
    
    #warning("extract subtypes to get rid of generics where they are not needed")
    struct UtilityServicePickerFlowState {
        
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

extension UtilityPaymentFlowState.Destination.UtilityServicePickerFlowState {
    
    struct Content {
        
        let services: MultiElementArray<UtilityService>
        let `operator`: Operator
    }
    
    typealias Alert = ServiceFailureAlert

    enum Destination {
        
        case payment(UtilityServicePaymentFlowState<PaymentViewModel>)
    }
}

extension UtilityPaymentFlowState.Destination.UtilityServicePickerFlowState.Destination {
    
    typealias StartPaymentResponse = StartUtilityPaymentResponse
}

extension UtilityPaymentFlowState.Destination.UtilityServicePickerFlowState.Content: Equatable where Operator: Equatable, UtilityService: Equatable {}
