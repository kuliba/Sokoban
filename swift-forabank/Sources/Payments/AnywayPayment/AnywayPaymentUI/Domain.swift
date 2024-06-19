//
//  Domain.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentDomain

public typealias AnywayTransactionState<DocumentStatus, Response> = Transaction<AnywayPaymentContext, Status<DocumentStatus, Response>>
public typealias AnywayTransactionEvent<DocumentStatus, Response> = TransactionEvent<Report<DocumentStatus, Response>, AnywayPaymentEvent, AnywayPaymentUpdate>
public typealias AnywayTransactionEffect = TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>

public typealias Status<DocumentStatus, Response> = TransactionStatus<AnywayPaymentContext, AnywayPaymentUpdate, Report<DocumentStatus, Response>>
public typealias Report<DocumentStatus, Response> = TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails<Response>>>

public typealias OperationDetailID = Int

public struct OperationDetails<Response> {
    
    public let id: OperationDetailID
    public let response: Response
    
    public init(
        id: OperationDetailID,
        response: Response
    ) {
        self.id = id
        self.response = response
    }
}

extension OperationDetails: Equatable where Response: Equatable {}
