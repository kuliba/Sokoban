//
//  InitiatePaymentPayload.swift
//  
//
//  Created by Igor Malyarov on 01.09.2024.
//

public enum InitiatePaymentPayload<Latest, Service> {
    
    case latest(Latest)
    case service(Service)
}

extension InitiatePaymentPayload: Equatable where Latest: Equatable, Service: Equatable {}
