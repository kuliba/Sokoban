//
//  ProcessProviderResult.swift
//  
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum ProcessProviderResult<Payment, Service> {
    
    case initiatePaymentResult(Result<Payment, ServiceFailure>)
    case services(Services)
    case servicesFailure
}

public extension ProcessProviderResult {
    
    typealias Services = MultiElementArray<Service>
}

extension ProcessProviderResult: Equatable where Payment: Equatable, Service: Equatable {}
