//
//  PaymentEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    case completePayment(TransactionResult)
    case `continue`
    case fraud(Fraud)
    case initiatePayment
    case parameter(ParameterEvent)
    case updatePayment(UpdateResult)
}

public extension PaymentEvent {
    
    enum Fraud: Equatable {
        
        case cancel, `continue`, expired
    }
    
    typealias TransactionResult = TransactionReport<DocumentStatus, OperationDetails>?
    
    typealias UpdateResult = Result<Update, ServiceFailure>
}

extension PaymentEvent: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable, ParameterEvent: Equatable, Update: Equatable {}
