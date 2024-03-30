//
//  PaymentState.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

import AnywayPaymentCore

struct PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    var payment: Payment
    var status: Status?
}

extension PaymentState {
    
    enum Status {
        
        case result(Result<Report, Terminated>)
        case serverError(String)
    }
}

extension PaymentState.Status {
    
    enum Terminated: Error {
        
        case transactionFailure
        case updateFailure
    }
}

extension PaymentState.Status {
    
    typealias Report = TransactionReport<DocumentStatus, OperationDetails>
}

extension PaymentState: Equatable where Payment: Equatable, DocumentStatus: Equatable, OperationDetails: Equatable {}
extension PaymentState.Status: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}
