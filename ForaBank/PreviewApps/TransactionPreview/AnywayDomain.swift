//
//  AnywayTransaction.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import RxViewModel

typealias ObservingCachedAnywayTransactionViewModel = RxObservingViewModel<AnywayTransactionState, AnywayTransactionEvent, TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>>

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
