//
//  UtilityServicePaymentFlowFactory.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct UtilityServicePaymentFlowFactory<Icon, OperatorPicker, ServicePicker>
where OperatorPicker: View,
      ServicePicker: View {
    
    let makeOperatorPicker: MakeOperatorPicker
    let makeServicePicker: MakeServicePicker
}

extension UtilityServicePaymentFlowFactory {
    
    typealias MakeOperatorPicker = () -> OperatorPicker
    
    typealias Service = UtilityService<Icon>
    typealias PickerState = UtilityServicePickerState<Icon>
    typealias MakeServicePicker = (PickerState, @escaping (Service) -> Void) -> ServicePicker
}
