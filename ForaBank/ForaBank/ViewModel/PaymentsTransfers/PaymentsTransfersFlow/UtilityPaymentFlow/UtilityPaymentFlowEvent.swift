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
        
        case addCompany
        case dismissAlert
        case dismissDestination
        case dismissOperatorFailureDestination
        case dismissServicesDestination
        case initiated(UtilityPrepaymentPayload)
        case payByInstructions
        case payByInstructionsFromError
        case paymentStarted(PaymentStarted)
        case select(Select)
    }
}

extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent {
    
    enum Select {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
        case service(UtilityService, for: Operator)
    }
    
    struct PaymentStarted {
        
        let select: Select
        let result: StartPaymentResult
    }
    
    struct UtilityPrepaymentPayload {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
        let searchText: String
    }
}

extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.PaymentStarted {
    
    typealias StartPaymentResult = Result<StartPaymentSuccess, StartPaymentFailure>
    
    enum StartPaymentSuccess {
        
        case services(MultiElementArray<UtilityService>, for: Operator)
        case startPayment(StartPaymentResponse)
        
        typealias StartPaymentResponse = StartUtilityPaymentResponse
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

extension UtilityPaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.Select: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.PaymentStarted: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.PaymentStarted.StartPaymentSuccess: Equatable where Operator: Equatable, UtilityService: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.PaymentStarted.StartPaymentFailure: Equatable where Operator: Equatable {}
extension UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable {}

typealias StartUtilityPaymentResponse = AnywayPaymentUpdate
