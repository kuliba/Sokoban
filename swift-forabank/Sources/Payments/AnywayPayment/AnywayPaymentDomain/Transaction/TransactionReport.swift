//
//  TransactionReport.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import Tagged

public struct TransactionReport<DocumentStatus, OperationDetails> {
    
    public let status: DocumentStatus
    public let details: Details
    
    public init(
        status: DocumentStatus,
        details: Details
    ) {
        self.status = status
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
