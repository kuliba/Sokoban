//
//  UtilityPrepaymentDestinationView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct UtilityPrepaymentDestinationView<OperatorFailureView, PaymentFlowView, ServicePicker>: View
where OperatorFailureView: View,
      PaymentFlowView: View,
      ServicePicker: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        switch state {
        case let .operatorFailure(operatorFailure):
            factory.makeOperatorFailureView(
                operatorFailure,
                { event(.prepayment(.payByInstructions)) },
                { event(.prepayment(.dismissOperatorFailureDestination)) }
            )
            .navigationTitle(String(describing: operatorFailure.operator))
            .navigationBarTitleDisplayMode(.inline)
            
        case .payByInstructions:
            Text("Pay by Instructions")
            
        case let .payment(state):
            factory.makePaymentFlowView(state, { event(.payment($0)) })
            
        case let .servicePicker(servicePickerState):
            factory.makeServicePicker(servicePickerState)
        }
    }
    
}

extension UtilityPrepaymentDestinationView {
    
    typealias OperatorFailure = UtilityPaymentFlowState.Destination.OperatorFailure
    
    typealias State = UtilityPaymentFlowState.Destination
#warning("`UtilityPaymentFlowEvent` is too brad here - need new narrower scope type and mapping at call site")
    typealias Event = UtilityPaymentFlowEvent
    typealias Factory = UtilityPrepaymentDestinationViewFactory<OperatorFailureView, PaymentFlowView, ServicePicker>
}

//#Preview {
//    UtilityPrepaymentDestinationView()
//}
