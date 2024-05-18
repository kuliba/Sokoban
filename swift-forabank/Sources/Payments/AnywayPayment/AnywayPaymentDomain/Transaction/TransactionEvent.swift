//
//  TransactionEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate> {
    
    case completePayment(TransactionResult)
    case `continue`
    case dismissRecoverableError
    case fraud(Fraud)
    case initiatePayment
    case payment(PaymentEvent)
    case updatePayment(UpdatePaymentResult)
}

public extension TransactionEvent {
    
    enum Fraud: Equatable {
        
        case cancel, `continue`, expired
    }
    
    typealias TransactionResult = TransactionReport<DocumentStatus, OperationDetails>?
    
    typealias UpdatePaymentResult = Result<PaymentUpdate, ServiceFailure>
}

extension TransactionEvent: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable, PaymentEvent: Equatable, PaymentUpdate: Equatable {}
