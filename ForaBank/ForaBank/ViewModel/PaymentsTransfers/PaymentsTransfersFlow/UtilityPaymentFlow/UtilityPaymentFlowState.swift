//
//  UtilityPaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

struct UtilityPaymentFlowState<Operator, UtilityService, Content, PaymentViewModel> {
    
    var alert: Alert?
    let content: Content
    var destination: Destination?
    let navTitle: String
}

extension UtilityPaymentFlowState {
    
    typealias Alert = ServiceFailureAlert
    
    #warning("make generic?")
    enum Destination {
        
        case operatorFailure(OperatorFailure)
        case payByInstructions(PayByInstructionsViewModel)
        case payment(Payment)
        case servicePicker(ServicePickerState)
    }
}

extension UtilityPaymentFlowState.Destination {
    
    typealias OperatorFailure = SberOperatorFailureFlowState<Operator>
    typealias PayByInstructionsViewModel = PaymentsViewModel
    typealias Payment = UtilityServicePaymentFlowState<PaymentViewModel>
    typealias ServicePickerState = UtilityServicePickerFlowState<Operator, UtilityService, PaymentViewModel>
}
