//
//  UtilityPrepaymentDestinationViewFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct UtilityPrepaymentDestinationViewFactory<OperatorFailureView, PayByInstructionsView, PaymentFlowView, ServicePicker>
where OperatorFailureView: View,
      PayByInstructionsView: View,
      PaymentFlowView: View,
      ServicePicker: View {
    
    let makeOperatorFailureView: MakeOperatorFailureView
    let makePayByInstructionsView: MakePayByInstructionsView
    let makePaymentFlowView: MakePaymentFlowView
    let makeServicePicker: (ServicePickerState) -> ServicePicker
}

extension UtilityPrepaymentDestinationViewFactory {
    
    typealias OperatorFailure = UtilityPaymentFlowState.Destination.OperatorFailure
    typealias MakeOperatorFailureView = (OperatorFailure) -> OperatorFailureView
    
    typealias MakePayByInstructionsView = () -> PayByInstructionsView
    
    typealias MakePaymentFlowView = (PaymentFlowState) -> PaymentFlowView
    
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerState
    typealias MakeServicePicker = (ServicePickerState) -> ServicePicker
}
