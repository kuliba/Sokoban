//
//  PrePaymentEvent.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentEvent<LastPayment, Operator, Response, Service> {
    
    case addCompany
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
    }
    
    typealias ResponseResult = Result<Response, ServiceFailure>
    
    enum LoadResult {
        
        case failure
        case list([Service])
    }
}

extension PrePaymentEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Response: Equatable, Service: Equatable {}
extension PrePaymentEvent.LoadResult: Equatable where Service: Equatable {}
extension PrePaymentEvent.SelectEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
