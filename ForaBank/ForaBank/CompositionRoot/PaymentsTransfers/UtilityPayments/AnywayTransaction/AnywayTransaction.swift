//
//  AnywayTransaction.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentBackend
import AnywayPaymentCore
import AnywayPaymentDomain
import RemoteServices
import RxViewModel

typealias CachedAnywayTransactionViewModel = RxViewModel<CachedTransactionState, CachedTransactionEvent, CachedTransactionEffect>

typealias CachedTransactionState = Transaction<CachedPaymentContext<AnywayElementModel>, AnywayTransactionStatus>
typealias CachedTransactionEvent = CachedAnywayTransactionEvent<AnywayTransactionState, AnywayTransactionEvent>
typealias CachedTransactionEffect = CachedAnywayTransactionEffect<AnywayTransactionEvent>

typealias AnywayTransactionViewModel = RxObservingViewModel<AnywayTransactionState, AnywayTransactionEvent, AnywayTransactionEffect>

typealias AnywayTransactionState = Transaction<AnywayPaymentContext, AnywayTransactionStatus>
typealias AnywayTransactionEvent = TransactionEvent<AnywayTransactionReport, AnywayPaymentEvent, AnywayPaymentUpdate>
typealias AnywayTransactionEffect = TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>

typealias AnywayTransactionEffectHandlerMicroServices = TransactionEffectHandlerMicroServices<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>

typealias AnywayTransactionStatus = TransactionStatus<AnywayTransactionReport>
typealias AnywayTransactionReport = TransactionReport<DocumentStatus, _OperationInfo>
#warning("rename _OperationInfo")
typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails>

enum DocumentStatus {
    
    case completed, inflight, rejected
}

typealias OperationDetailID = Int
typealias OperationDetails = RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse
