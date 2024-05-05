//
//  UtilityPrepaymentDestinationView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct UtilityPrepaymentDestinationView<OperatorFailureView, PayByInstructionsView, PaymentFlowView, ServicePicker>: View
where OperatorFailureView: View,
      PayByInstructionsView: View,
      PaymentFlowView: View,
      ServicePicker: View {
    
    let state: State
    let factory: Factory
    
    var body: some View {
        
        switch state {
        case let .operatorFailure(operatorFailure):
            factory.makeOperatorFailureView(operatorFailure)
            
        case .payByInstructions:
            factory.makePayByInstructionsView()
            
        case let .payment(state):
            factory.makePaymentFlowView(state)
            
        case let .servicePicker(servicePickerState):
            factory.makeServicePicker(servicePickerState)
        }
    }
    
}

extension UtilityPrepaymentDestinationView {
    
    typealias OperatorFailure = UtilityPaymentFlowState.Destination.OperatorFailure
    
    typealias State = UtilityPaymentFlowState.Destination
    typealias Factory = UtilityPrepaymentDestinationViewFactory<OperatorFailureView, PayByInstructionsView, PaymentFlowView, ServicePicker>
}

//#Preview {
//    UtilityPrepaymentDestinationView()
//}
