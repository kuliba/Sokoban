//
//  ProcessProviderResult.swift
//  
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum ProcessProviderResult<Payment, Service, ServicesFailure> {
    
    case initiatePaymentResult(Result<Payment, ServiceFailure>)
    case servicesResult(ServicesResult<Service, ServicesFailure>)
}

extension ProcessProviderResult: Equatable where Payment: Equatable, Service: Equatable, ServicesFailure: Equatable {}
