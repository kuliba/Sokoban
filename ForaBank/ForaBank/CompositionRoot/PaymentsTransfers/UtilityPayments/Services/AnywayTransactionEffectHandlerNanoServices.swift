//
//  AnywayTransactionEffectHandlerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import RemoteServices

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
    
    typealias GetDetailsResponse = RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse
    typealias GetDetailsResult = GetDetailsResponse?
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias GetDetails = (OperationDetailID, @escaping GetDetailsCompletion) -> Void
    
    typealias MakeTransferResult = MakeTransferResponse?
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (VerificationCode, @escaping MakeTransferCompletion) -> Void
}

extension AnywayTransactionEffectHandlerNanoServices {
    
#warning("reuse generic TransactionReport")
    struct MakeTransferResponse {
        
        let status: DocumentStatus
        let detailID: OperationDetailID
    }
}
