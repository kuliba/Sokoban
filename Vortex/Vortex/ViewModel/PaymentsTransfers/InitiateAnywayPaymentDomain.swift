//
//  InitiateAnywayPaymentDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.12.2024.
//

import VortexTools

enum InitiateAnywayPaymentDomain<Payment, Operator, Service, OperatorServices, StartPayment> {
    
    enum Select {
        
        case oneOf(Service, for: Operator) // in case of multiple services the payment should have a field representing selected service
        case `operator`(Operator)
        case payment(Payment)
        case singleService(Service, for: Operator)
    }
    
    typealias Result = Swift.Result<Success, Failure>
    
    enum Success {
        
        case services(OperatorServices)
        case startPayment(StartPayment)
    }
    
    enum Failure: Error {
        
        case operatorFailure(Operator)
        case serviceFailure(ServiceFailureAlert.ServiceFailure)
    }
}

extension InitiateAnywayPaymentDomain.Select: Equatable where Payment: Equatable, Operator: Equatable, Service: Equatable {}
extension InitiateAnywayPaymentDomain.Success: Equatable where Operator: Equatable, Service: Equatable, OperatorServices: Equatable, StartPayment: Equatable {}
extension InitiateAnywayPaymentDomain.Failure: Equatable where Operator: Equatable {}

// MARK: - OperatorServices

struct OperatorServices<Operator, Service> {
    
    let services: MultiElementArray<Service>
    let `operator`: Operator
}

extension OperatorServices: Equatable where Operator: Equatable, Service: Equatable {}
