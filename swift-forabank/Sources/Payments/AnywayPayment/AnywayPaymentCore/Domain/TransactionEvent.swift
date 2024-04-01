//
//  TransactionEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, Update> {
    
    case completePayment(TransactionResult)
    case `continue`
    case dismissRecoverableError
    case fraud(Fraud)
    case initiatePayment
    case payment(PaymentEvent)
    case updatePayment(UpdateResult)
}

public extension TransactionEvent {
    
    enum Fraud: Equatable {
        
        case cancel, `continue`, expired
    }
    
    typealias TransactionResult = TransactionReport<DocumentStatus, OperationDetails>?
    
    typealias UpdateResult = Result<Update, ServiceFailure>
}

extension TransactionEvent: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable, PaymentEvent: Equatable, Update: Equatable {}
