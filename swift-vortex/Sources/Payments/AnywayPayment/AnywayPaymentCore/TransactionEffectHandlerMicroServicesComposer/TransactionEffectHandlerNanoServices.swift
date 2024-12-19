//
//  TransactionEffectHandlerNanoServices.swift
//
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentDomain

#warning("move to Composition Root, remove generics")
struct TransactionEffectHandlerNanoServices<DocumentStatus, OperationDetailID, OperationDetails> {
    
    let getDetails: GetDetails
    let makeTransfer: MakeTransfer
}

extension TransactionEffectHandlerNanoServices {
    
    typealias Report = TransactionReport<DocumentStatus, _OperationInfo>
    typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails>
    
    typealias GetDetailsResult = OperationDetails?
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias GetDetails = (OperationDetailID, @escaping GetDetailsCompletion) -> Void
    
    typealias MakeTransferResult = MakeTransferResponse?
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (VerificationCode, @escaping MakeTransferCompletion) -> Void
}

extension TransactionEffectHandlerNanoServices {
    
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
