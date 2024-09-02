//
//  PaymentProviderPickerFlowDestination.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum PaymentProviderPickerFlowDestination<PayByInstructions, Payment, ServicePicker, ServicesFailure> {
    
    case payByInstructions(PayByInstructions)
    case payment(Payment)
    case servicePicker(ServicePicker)
    case servicesFailure(ServicesFailure)
}

extension PaymentProviderPickerFlowDestination: Equatable where PayByInstructions: Equatable, Payment: Equatable, ServicePicker: Equatable, ServicesFailure: Equatable {}
