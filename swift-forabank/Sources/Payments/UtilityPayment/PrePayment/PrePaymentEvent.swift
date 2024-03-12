//
//  PrePaymentEvent.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

#warning("rename/move to FlowEvent?")
public enum PrePaymentEvent<LastPayment, Operator, Response, Service> {
    
    case loaded(LoadResult)
    case payByInstruction
    case scan
    case select(SelectEvent)
    case paymentStarted(ResponseResult)
}

public extension PrePaymentEvent {
    
    enum SelectEvent {
        
        case last(LastPayment)
        case `operator`(Operator)
        case service(Service)
    }
    
    typealias ResponseResult = Result<Response, ServiceFailure>
    
    enum LoadResult {
        
        case failure
        case list(Operator, [Service]) // list of many (more than one)
    }
}

extension PrePaymentEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Response: Equatable, Service: Equatable {}
extension PrePaymentEvent.LoadResult: Equatable where Operator: Equatable, Service: Equatable {}
extension PrePaymentEvent.SelectEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
