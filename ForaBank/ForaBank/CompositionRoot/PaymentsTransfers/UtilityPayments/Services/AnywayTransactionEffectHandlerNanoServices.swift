//
//  AnywayTransactionEffectHandlerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain

struct AnywayTransactionEffectHandlerNanoServices {
    
    let initiatePayment: InitiatePayment
    let getDetails: GetDetails
    let makeTransfer: MakeTransfer
    let processPayment: ProcessPayment
}

extension AnywayTransactionEffectHandlerNanoServices {
    
    typealias InitiatePayment = ProcessPayment
    
    typealias ProcessResult = Result<AnywayPaymentUpdate, ServiceFailure>
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias ProcessPayment = (AnywayPaymentDigest, @escaping ProcessCompletion) -> Void
    
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
