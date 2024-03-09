//
//  PrePaymentEvent.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentEvent<LastPayment, Operator, Response> {
    
    case addCompany
    case back
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
}

extension PrePaymentEvent: Equatable where LastPayment: Equatable, Operator: Equatable, Response: Equatable {}
extension PrePaymentEvent.SelectEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
