//
//  AnywayTransaction.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import RxViewModel

typealias ObservingCachedAnywayTransactionViewModel = RxObservingViewModel<CachedTransactionState, CachedTransactionEvent, CachedTransactionEffect>
typealias CachedTransactionState = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, CachedPaymentContext<AnywayElement>>
typealias CachedTransactionEvent = CachedAnywayTransactionEvent<AnywayTransactionState, AnywayTransactionEvent>
typealias CachedTransactionEffect = CachedAnywayTransactionEffect<AnywayTransactionEvent>

typealias ObservingAnywayTransactionViewModel = RxViewModel<AnywayTransactionState, AnywayTransactionEvent, TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>>

typealias AnywayTransactionViewModel = RxViewModel<AnywayTransactionState, AnywayTransactionEvent, TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>>

typealias AnywayTransactionState = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, AnywayPaymentContext>

typealias AnywayTransactionEvent = TransactionEventOf<OperationDetailID, OperationDetails, DocumentStatus, AnywayPaymentEvent, AnywayPaymentUpdate>

typealias AnywayTransactionEffectHandlerMicroServices = TransactionEffectHandlerMicroServices<Report, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>

typealias Report = TransactionReport<DocumentStatus, _OperationInfo>
typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails>

enum DocumentStatus {
    
    case completed, inflight, rejected
}

typealias OperationDetailID = Int
typealias OperationDetails = String
