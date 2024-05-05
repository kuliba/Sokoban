//
//  UtilityPrepaymentDestinationViewFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct UtilityPrepaymentDestinationViewFactory<PaymentFlowView, ServicePicker>
where PaymentFlowView: View,
      ServicePicker: View {
    
    let makePaymentFlowView: MakePaymentFlowView
    let makeServicePicker: (ServicePickerState) -> ServicePicker
}

extension UtilityPrepaymentDestinationViewFactory {
    
    typealias MakePaymentFlowView = (PaymentFlowState, @escaping (UtilityServicePaymentFlowEvent) -> Void) -> PaymentFlowView
    
    typealias ServicePickerState = UtilityPaymentFlowState.Destination.ServicePickerState
    typealias MakeServicePicker = (ServicePickerState) -> ServicePicker
}
