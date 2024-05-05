//
//  UtilityPrepaymentDestinationView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct UtilityPrepaymentDestinationView<PaymentFlowView, ServicePicker>: View
where PaymentFlowView: View,
      ServicePicker: View {
    
    let state: State
    let event: (Event) -> Void
#warning("move to factory")
    let paymentFlowView: (PaymentFlowState, @escaping (UtilityServicePaymentFlowEvent) -> Void) -> PaymentFlowView
    let servicePicker: (ServicePickerState) -> ServicePicker
    
    var body: some View {
        
        switch state {
        case let .operatorFailure(operatorFailure):
            operatorFailureView(
                operatorFailure,
                payByInstructions: { event(.prepayment(.payByInstructions)) },
                dismissDestination: { event(.prepayment(.dismissOperatorFailureDestination)) }
            )
            .navigationTitle(String(describing: operatorFailure.operator))
            .navigationBarTitleDisplayMode(.inline)
            
        case .payByInstructions:
            Text("Pay by Instructions")
            
        case let .payment(state):
            paymentFlowView(state, { event(.payment($0)) })
                .navigationTitle("Payment")
                .navigationBarTitleDisplayMode(.inline)
            
        case let .servicePicker(servicePickerState):
            servicePicker(servicePickerState)
                .navigationTitle(String(describing: servicePickerState.operator))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
#warning("multiple closures could be encapsulated into one `event: (Event) -> Void closure`")
    #warning("move to factory")
    private func operatorFailureView(
        _ operatorFailure: OperatorFailure,
        payByInstructions: @escaping () -> Void,
        dismissDestination: @escaping () -> Void
    ) -> some View {
        
        VStack(spacing: 32) {
            
            Text("TBD: Operator Failure view for \(operatorFailure.operator)")
            
            Button("Pay by Instructions", action: payByInstructions)
        }
        .navigationDestination(
            destination: operatorFailure.destination,
            dismissDestination: dismissDestination,
            content: operatorFailureDestinationView
        )
    }
    
    @ViewBuilder
    private func operatorFailureDestinationView(
        destination: OperatorFailure.Destination
    ) -> some View {
        
        Text("TBD: Pay by Instructions (OperatorFailure.Destination)")
    }
}

extension UtilityPrepaymentDestinationView {
    
    typealias OperatorFailure = UtilityPaymentFlowState.Destination.OperatorFailure
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerState
    
    typealias State = UtilityPaymentFlowState.Destination
#warning("`UtilityPaymentFlowEvent` is too brad here - need new narrower scope type and mapping at call site")
    typealias Event = UtilityPaymentFlowEvent
}

//#Preview {
//    UtilityPrepaymentDestinationView()
//}
