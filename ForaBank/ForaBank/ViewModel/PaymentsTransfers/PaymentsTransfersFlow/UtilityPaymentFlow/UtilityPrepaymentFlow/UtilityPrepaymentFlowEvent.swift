//
//  UtilityPrepaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.06.2024.
//

import ForaTools

enum UtilityPrepaymentFlowEvent<LastPayment, Operator, Service> {
    
    case dismiss(Dismiss)
    case initiated(Initiated)
    case outside(Outside)
    case payByInstructions
    case payByInstructionsFromError
    case paymentStarted(StartPaymentResult)
    case select(Select)
}

extension UtilityPrepaymentFlowEvent {
    
    enum Dismiss {
        
        case alert
        case destination
        case operatorFailureDestination
        case servicesDestination
    }
    
    enum Initiated {
        
        case legacy(PaymentsServicesViewModel)
        case v1(UtilityPrepaymentPayload)
    }
    
    enum Outside {
        
        case addCompany
    }
    
    enum Select {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
        case service(Service, for: Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentSuccess, StartPaymentFailure>
    
    enum StartPaymentSuccess {
        
        case services(MultiElementArray<Service>, for: Operator)
        case startPayment(AnywayTransactionState)
    }
    
    enum StartPaymentFailure: Error {
        
        case operatorFailure(Operator)
        case serviceFailure(ServiceFailure)
        
#warning("extract…")
        enum ServiceFailure: Error, Hashable {
            
            case connectivityError
            case serverError(String)
        }
    }
}

extension UtilityPrepaymentFlowEvent.Initiated: Equatable where LastPayment: Equatable, Operator: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.legacy(lhs), .legacy(rhs)):
            return lhs === rhs
            
        case let (.v1(lhs), .v1(rhs)):
            return lhs == rhs
            
        default:
            return false
        }
    }
}

extension UtilityPrepaymentFlowEvent.Initiated {
    
    struct UtilityPrepaymentPayload {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
        let searchText: String
    }
}

extension UtilityPrepaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
extension UtilityPrepaymentFlowEvent.Select: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
extension UtilityPrepaymentFlowEvent.StartPaymentSuccess: Equatable where Operator: Equatable, Service: Equatable {}
extension UtilityPrepaymentFlowEvent.StartPaymentFailure: Equatable where Operator: Equatable {}
extension UtilityPrepaymentFlowEvent.Initiated.UtilityPrepaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable {}
