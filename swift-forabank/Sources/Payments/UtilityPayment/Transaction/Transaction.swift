//
//  Transaction.swift
//
//
//  Created by Igor Malyarov on 04.03.2024.
//

import Tagged

public enum UtilityPaymentState: Equatable {
    
    case payment(UtilityPayment)
    case result(TransferResult)
}

public struct UtilityPayment: Equatable {
    
    #warning("TBD")
    // snapshots stack
    // fields
    
    public init() {}
}

public typealias TransferResult = Result<Transaction, TransactionFailure>

// `g1`
public struct Transaction: Equatable {
    
    public let paymentOperationDetailID: PaymentOperationDetailID
    public let documentStatus: DocumentStatus
    
    public init(
        paymentOperationDetailID: PaymentOperationDetailID,
        documentStatus: DocumentStatus
    ) {
        self.paymentOperationDetailID = paymentOperationDetailID
        self.documentStatus = documentStatus
    }
}

public extension Transaction {
    
    typealias PaymentOperationDetailID = Tagged<_PaymentOperationDetailID, Int>
    enum _PaymentOperationDetailID {}
    
    enum DocumentStatus {
        
        case complete, inProgress, rejected
    }
}

public enum TransactionFailure: Error, Equatable {
    
    case fraud(Fraud)
    // `g2/g3/g4`
    case transferError
}

public extension TransactionFailure {
    
    enum Fraud {
        
        case cancelled, expired
    }
}
