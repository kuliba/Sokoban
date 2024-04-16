//
//  TransactionReport.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import Tagged

public struct TransactionReport<DocumentStatus, OperationDetails> {
    
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

public extension TransactionReport {
    
    enum Details {
        
        case paymentOperationDetailID(PaymentOperationDetailID)
        case operationDetails(OperationDetails)
    }
}

public extension TransactionReport.Details {
    
    typealias PaymentOperationDetailID = Tagged<_PaymentOperationDetailID, Int>
    enum _PaymentOperationDetailID {}
}

extension TransactionReport: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}
extension TransactionReport.Details: Equatable where OperationDetails: Equatable {}
