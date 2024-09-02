//
//  PaymentProviderPickerDestination.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum PaymentProviderPickerDestination<PayByInstructions, Payment, ServicePicker, ServicesFailure> {
    
    case backendFailure(BackendFailure)
    case payByInstructions(PayByInstructions)
    case payment(Payment)
    case servicePicker(ServicePicker)
    case servicesFailure(ServicesFailure)
}

extension PaymentProviderPickerDestination: Equatable where PayByInstructions: Equatable, Payment: Equatable, ServicePicker: Equatable, ServicesFailure: Equatable {}
