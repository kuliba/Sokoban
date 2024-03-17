//
//  UtilityFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

public enum UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse> {
    
    case back
    case initiate
    case loaded(Loaded)
    case paymentStarted(StartPaymentResult)
    case select(Select)
    case selectFailure(Operator)
    case loadedServices([Service]) // more than one
}

public extension UtilityFlowEvent {
    
    enum Loaded {
        
        case failure
        case success([LastPayment], [Operator])
    }
    
    enum Select {
        
        case last(LastPayment)
        case `operator`(Operator)
        case service(Service, for: Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentResponse, ServiceFailure>
}

extension UtilityFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable, StartPaymentResponse: Equatable {}
extension UtilityFlowEvent.Loaded: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension UtilityFlowEvent.Select: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
