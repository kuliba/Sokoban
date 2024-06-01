//
//  UtilityPaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import ForaTools
import AnywayPaymentDomain

enum UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService> {
    
    case payment(UtilityServicePaymentFlowEvent)
    case prepayment(UtilityPrepaymentFlowEvent)
    case servicePicker(ServicePickerFlowEvent)
}

extension UtilityPaymentFlowEvent {
    
    enum ServicePickerFlowEvent: Equatable {
        
        case dismissAlert
    }
    
    enum UtilityPrepaymentFlowEvent {
        
        case dismissAlert
        case dismissDestination
        case dismissOperatorFailureDestination
        case dismissServicesDestination
        case initiated(Initiated)
        case outside(Outside)
        case payByInstructions
        case payByInstructionsFromError
        case paymentStarted(StartPaymentResult)
        case select(Select)
        
        #warning("extract to extension")
        enum Outside {
            
            case addCompany
        }
    }
}

extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent {
    
    enum Initiated {
        
        case legacy(PaymentsServicesViewModel)
        case v1(UtilityPrepaymentPayload)
    }
    
    enum Select {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
        case service(UtilityService, for: Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentSuccess, StartPaymentFailure>
    
    enum StartPaymentSuccess {
        
        case services(MultiElementArray<UtilityService>, for: Operator)
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

extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.Initiated: Equatable where LastPayment: Equatable, Operator: Equatable {
    
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

extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.Initiated {
    
    struct UtilityPrepaymentPayload {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
        let searchText: String
    }
}

extension UtilityPaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.Select: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentSuccess: Equatable where Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentFailure: Equatable where Operator: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.Initiated.UtilityPrepaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable {}
