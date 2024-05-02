//
//  UtilityServicePaymentFlowFactory.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import UIPrimitives
import SwiftUI

struct UtilityServicePaymentFlowFactory<Icon, OperatorPicker, ServicePicker>
where OperatorPicker: View,
      ServicePicker: View {
    
    let asyncImage: MakeAsyncImage
    let makeOperatorPicker: MakeOperatorPicker
    // TODO: replace with MakeDestinationView
    let makeServicePicker: MakeServicePicker
}

extension UtilityServicePaymentFlowFactory {
    
    typealias MakeAsyncImage = (Icon) -> UIPrimitives.AsyncImage
    
    typealias OperatorPickerState = UtilityPaymentOperatorPickerState<Icon>
    typealias OperatorPickerEvent = UtilityPaymentOperatorPickerEvent<Icon>
    typealias MakeOperatorPicker = (@escaping (OperatorPickerEvent) -> Void) -> OperatorPicker
    
    typealias Service = UtilityService<Icon>
    typealias ServicePickerState = UtilityServicePickerState<Icon>
    typealias MakeServicePicker = (ServicePickerState, @escaping (Service) -> Void) -> ServicePicker
}
