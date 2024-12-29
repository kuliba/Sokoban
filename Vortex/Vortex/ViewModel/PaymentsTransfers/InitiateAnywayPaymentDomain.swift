//
//  InitiateAnywayPaymentDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.12.2024.
//

import VortexTools

enum InitiateAnywayPaymentDomain<Latest, Operator, Service, StartPayment> {
    
    enum Select {
        
        case lastPayment(Latest)
        case `operator`(Operator)
        case oneOf(Service, for: Operator) // in case of multiple services the payment should have a field representing selected service
        case singleService(Service, for: Operator)
    }
    
    typealias Result = Swift.Result<Success, Failure>
    
    enum Success {
        
        case services(OperatorServices)
        case startPayment(StartPayment)
        
        struct OperatorServices {
            
            let services: MultiElementArray<Service>
            let `operator`: Operator
        }
    }
    
    enum Failure: Error {
        
        case operatorFailure(Operator)
        case serviceFailure(ServiceFailureAlert.ServiceFailure)
    }
}

extension InitiateAnywayPaymentDomain.Select: Equatable where Latest: Equatable, Operator: Equatable, Service: Equatable {}
extension InitiateAnywayPaymentDomain.Success: Equatable where Operator: Equatable, Service: Equatable, StartPayment: Equatable {}
    extension InitiateAnywayPaymentDomain.Success.OperatorServices: Equatable where Operator: Equatable, Service: Equatable {}
extension InitiateAnywayPaymentDomain.Failure: Equatable where Operator: Equatable {}
