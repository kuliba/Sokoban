//
//  ProcessProviderResult.swift
//  
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum ProcessProviderResult<Payment, ServicePicker, ServicesFailure> {
    
    case initiatePaymentResult(Result<Payment, ServiceFailure>)
    case servicesResult(ServicesResult<ServicePicker, ServicesFailure>)
}

extension ProcessProviderResult: Equatable where Payment: Equatable, ServicePicker: Equatable, ServicesFailure: Equatable {}
