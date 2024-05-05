//
//  UtilityPrepaymentDestinationViewFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct UtilityPrepaymentDestinationViewFactory<OperatorFailureView, PaymentFlowView, ServicePicker>
where OperatorFailureView: View,
      PaymentFlowView: View,
      ServicePicker: View {
    
    let makeOperatorFailureView: MakeOperatorFailureView
    let makePaymentFlowView: MakePaymentFlowView
    let makeServicePicker: (ServicePickerState) -> ServicePicker
}

extension UtilityPrepaymentDestinationViewFactory {
    
    typealias OperatorFailure = UtilityPaymentFlowState.Destination.OperatorFailure
    typealias MakeOperatorFailureView = (OperatorFailure, @escaping () -> Void, @escaping () -> Void) -> OperatorFailureView
    
    typealias MakePaymentFlowView = (PaymentFlowState, @escaping (UtilityServicePaymentFlowEvent) -> Void) -> PaymentFlowView
    
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerState
    typealias MakeServicePicker = (ServicePickerState) -> ServicePicker
}
