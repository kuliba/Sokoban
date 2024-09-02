//
//  PaymentProviderPickerDestination.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure> {
    
    case backendFailure(BackendFailure)
    case detailPayment(DetailPayment)
    case payment(Payment)
    case servicePicker(ServicePicker)
    case servicesFailure(ServicesFailure)
}

extension PaymentProviderPickerDestination: Equatable where DetailPayment: Equatable, Payment: Equatable, ServicePicker: Equatable, ServicesFailure: Equatable {}
