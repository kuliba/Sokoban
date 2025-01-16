//
//  ProcessPaymentProviderDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.12.2024.
//

import VortexTools

// RootViewModelFactory+handleSelected.swift:257
/// A namespace.
enum ProcessPaymentProviderDomain<Operator, Service, StartPaymentResult> {}

extension ProcessPaymentProviderDomain {
    
    typealias Payload = Operator
    
    enum Response {
        
        /// `d3-d5`
        case operatorFailure(Operator)
        /// `d1`
        case services(MultiElementArray<Service>, for: Operator)
        /// Success: `d2, e1`, Failure: `d2, e2-e4`
        case startPayment(StartPaymentResult)
    }
}

extension ProcessPaymentProviderDomain.Response: Equatable where Operator: Equatable, Service: Equatable, StartPaymentResult: Equatable {}
