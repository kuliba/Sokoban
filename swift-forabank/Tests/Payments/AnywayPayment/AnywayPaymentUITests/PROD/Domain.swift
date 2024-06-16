//
//  Domain.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentDomain

typealias AnywayTransactionState<DocumentStatus, Response> = Transaction<AnywayPaymentContext, Status<DocumentStatus, Response>>
typealias AnywayTransactionEvent<DocumentStatus, Response> = TransactionEvent<Report<DocumentStatus, Response>, AnywayPaymentEvent, AnywayPaymentUpdate>
typealias AnywayTransactionEffect = TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>

typealias Status<DocumentStatus, Response> = TransactionStatus<Report<DocumentStatus, Response>>
typealias Report<DocumentStatus, Response> = TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails<Response>>>

typealias OperationDetailID = Int

struct OperationDetails<Response> {
    
    let id: OperationDetailID
    let response: Response
}

extension OperationDetails: Equatable where Response: Equatable {}
