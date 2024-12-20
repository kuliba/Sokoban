//
//  PaymentProviderPickerNavigation.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import VortexTools

public enum PaymentProviderPickerNavigation<DetailPayment, Payment, ServicePicker, ServicesFailure> {
    
    case backendFailure(BackendFailure)
    case detailPayment(DetailPayment)
    case payment(Payment)
    case servicePicker(ServicePicker)
    case servicesFailure(ServicesFailure)
}

extension PaymentProviderPickerNavigation: Equatable where DetailPayment: Equatable, Payment: Equatable, ServicePicker: Equatable, ServicesFailure: Equatable {}
