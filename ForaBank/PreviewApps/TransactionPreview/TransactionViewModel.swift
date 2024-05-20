//
//  TransactionViewModel.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import RxViewModel

typealias TransactionViewModel = RxViewModel<TransactionState, TransactionEvent, TransactionEffect<PaymentDigest, PaymentEffect>>

typealias TransactionState = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, Payment>

typealias TransactionEvent = TransactionEventOf<OperationDetailID, OperationDetails, DocumentStatus, PaymentEvent, PaymentUpdate>

typealias _TransactionReport = TransactionReport<DocumentStatus, _OperationInfo>
typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails>

enum DocumentStatus {
    
    case completed, inflight, rejected
}

typealias OperationDetailID = Int
typealias OperationDetails = String

typealias _TransactionEffectHandlerMicroServices = TransactionEffectHandlerMicroServices<_TransactionReport, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate>

typealias Payment = Int

enum PaymentEvent {
    
    case anEvent
}

enum PaymentEffect {
    
    case anEffect
}

typealias PaymentDigest = Int
typealias PaymentUpdate = Int
