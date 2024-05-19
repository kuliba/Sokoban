//
//  TransactionEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum TransactionEvent<TransactionReport, PaymentEvent, PaymentUpdate> {
    
    case completePayment(TransactionReport?)
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
        
    typealias UpdatePaymentResult = Result<PaymentUpdate, ServiceFailure>
}

extension TransactionEvent: Equatable where TransactionReport: Equatable, PaymentEvent: Equatable, PaymentUpdate: Equatable {}
