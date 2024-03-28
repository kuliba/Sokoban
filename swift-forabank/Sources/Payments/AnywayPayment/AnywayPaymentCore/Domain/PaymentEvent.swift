//
//  PaymentEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum PaymentEvent<DocumentStatus, OperationDetails, Update> {
    
    case update(UpdateResult)
    case completePayment(TransactionResult)
}

public extension PaymentEvent {
    
    typealias TransactionResult = TransactionDetails<DocumentStatus, OperationDetails>?
    
    typealias UpdateResult = Result<Update, ServiceFailure>
}

extension PaymentEvent: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable, Update: Equatable {}
