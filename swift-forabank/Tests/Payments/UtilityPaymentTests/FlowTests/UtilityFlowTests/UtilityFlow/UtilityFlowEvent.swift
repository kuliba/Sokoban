//
//  UtilityFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

enum UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse> {
    
    case back
    case initiate
    case loaded(Loaded)
    case paymentStarted(StartPaymentResult)
    case select(Select)
}

extension UtilityFlowEvent {
    
    enum Loaded {
        
        case failure
        case success([LastPayment], [Operator])
    }
    
    enum Select {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentResponse, ServiceFailure>
}

extension UtilityFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, StartPaymentResponse: Equatable {}

extension UtilityFlowEvent.Loaded: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension UtilityFlowEvent.Select: Equatable where LastPayment: Equatable, Operator: Equatable {}
