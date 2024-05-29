//
//  AnywayTransactionEffectHandlerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain

struct AnywayTransactionEffectHandlerNanoServices {
    
    let getDetails: GetDetails
    let makeTransfer: MakeTransfer
}

extension AnywayTransactionEffectHandlerNanoServices {
    
    typealias GetDetailsResult = OperationDetails?
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias GetDetails = (OperationDetailID, @escaping GetDetailsCompletion) -> Void
    
    typealias MakeTransferResult = MakeTransferResponse?
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (VerificationCode, @escaping MakeTransferCompletion) -> Void
}

extension AnywayTransactionEffectHandlerNanoServices {
    
#warning("reuse generic TransactionReport")
    public struct MakeTransferResponse {
        
        public let status: DocumentStatus
        public let detailID: OperationDetailID
        
        public init(
            status: DocumentStatus,
            detailID: OperationDetailID
        ) {
            self.status = status
            self.detailID = detailID
        }
    }
}
