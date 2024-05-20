//
//  TransactionReport.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public struct TransactionReport<DocumentStatus, OperationInfo> {
    
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

extension TransactionReport: Equatable where DocumentStatus: Equatable, OperationInfo: Equatable {}
