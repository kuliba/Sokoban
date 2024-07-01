//
//  AnywayTransactionEffectHandlerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import RemoteServices

struct AnywayTransactionEffectHandlerNanoServices {
    
    let getVerificationCode: GetVerificationCode
    let initiatePayment: InitiatePayment
    let getDetails: GetDetails
    let makeTransfer: MakeTransfer
    let processPayment: ProcessPayment
}

extension AnywayTransactionEffectHandlerNanoServices {
    
    typealias GetVerificationCodeResult = Result<Int, ServiceFailure>
    typealias GetVerificationCodeCompletion = (GetVerificationCodeResult) -> Void
    typealias GetVerificationCode = (@escaping GetVerificationCodeCompletion) -> Void
    
    typealias InitiatePayment = ProcessPayment
    
    typealias ProcessResult = Result<AnywayPaymentUpdate, ServiceFailure>
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias ProcessPayment = (AnywayPaymentDigest, @escaping ProcessCompletion) -> Void
    
    typealias GetDetailsResponse = RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse
    typealias GetDetailsResult = GetDetailsResponse?
    typealias GetDetailsCompletion = (GetDetailsResult) -> Void
    typealias GetDetails = (OperationDetailID, @escaping GetDetailsCompletion) -> Void
    
    enum MakeTransferFailure: Equatable, Error {
        
        case otpFailure(String)
        case terminal
    }
    typealias MakeTransferResult = Result<MakeTransferResponse, MakeTransferFailure>
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
