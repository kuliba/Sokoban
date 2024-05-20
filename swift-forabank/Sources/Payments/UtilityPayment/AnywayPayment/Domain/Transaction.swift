//
//  Transaction.swift
//
//
//  Created by Igor Malyarov on 04.03.2024.
//

import Tagged

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
