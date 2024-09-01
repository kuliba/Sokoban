//
//  PaymentProviderPickerFlowDestination.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum PaymentProviderPickerFlowDestination<PayByInstructions, Payment, Service, ServicesFailure> {
    
    case payByInstructions(PayByInstructions)
    case payment(Payment)
    case services(Services)
    case servicesFailure(ServicesFailure)
    
    public typealias Services = MultiElementArray<Service>
}

extension PaymentProviderPickerFlowDestination: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable, ServicesFailure: Equatable {}
