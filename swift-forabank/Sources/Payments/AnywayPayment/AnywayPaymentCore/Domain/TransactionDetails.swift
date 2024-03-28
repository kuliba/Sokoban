//
//  TransactionDetails.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import Tagged

public struct TransactionDetails<DocumentStatus, OperationDetails> {
    
    public let documentStatus: DocumentStatus
    public let details: Details
    
    public init(
        documentStatus: DocumentStatus,
        details: Details
    ) {
        self.documentStatus = documentStatus
        self.details = details
    }
}

public extension TransactionDetails {
    
    enum Details {
        
        case paymentOperationDetailID(PaymentOperationDetailID)
        case operationDetails(OperationDetails)
    }
}

public extension TransactionDetails.Details {
    
    typealias PaymentOperationDetailID = Tagged<_PaymentOperationDetailID, Int>
    enum _PaymentOperationDetailID {}
}

extension TransactionDetails: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}
extension TransactionDetails.Details: Equatable where OperationDetails: Equatable {}
