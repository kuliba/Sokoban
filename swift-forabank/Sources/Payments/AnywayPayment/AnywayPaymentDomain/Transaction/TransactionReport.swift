//
//  TransactionReport.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import Tagged

public struct TransactionReport<DocumentStatus, OperationDetails> {
    
    public let status: DocumentStatus
    public let info: OperationInfo
    
    public init(
        status: DocumentStatus,
        info: OperationInfo
    ) {
        self.status = status
        self.info = info
    }
}

public extension TransactionReport {
    
    enum OperationInfo {
        
        /// `paymentOperationDetailId`
        case detailID(PaymentOperationDetailID)
        case details(OperationDetails)
    }
}

public extension TransactionReport.OperationInfo {
    
    typealias PaymentOperationDetailID = Tagged<_PaymentOperationDetailID, Int>
    enum _PaymentOperationDetailID {}
}

extension TransactionReport: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}
extension TransactionReport.OperationInfo: Equatable where OperationDetails: Equatable {}
