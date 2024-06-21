//
//  AnywayTransaction.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import AnywayPaymentUI
import PaymentComponents
import RemoteServices
import RxViewModel

typealias AnywayTransactionViewModel = AnywayPaymentUI.AnywayTransactionViewModel<Node<BottomAmountViewModel>, AnywayElementModel, DocumentStatus, RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>

typealias AnywayTransactionState = AnywayPaymentUI.CachedModelsTransaction<Node<BottomAmountViewModel>, AnywayElementModel, DocumentStatus, RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>
typealias AnywayTransactionEvent = AnywayPaymentUI.AnywayTransactionEvent<DocumentStatus, RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>
typealias AnywayTransactionEffect = AnywayPaymentUI.AnywayTransactionEffect

typealias AnywayTransactionEffectHandlerMicroServices = TransactionEffectHandlerMicroServices<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>

typealias AnywayTransactionStatus = AnywayPaymentUI.Status<DocumentStatus, RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>
typealias AnywayTransactionReport = AnywayPaymentUI.Report<DocumentStatus, RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>
typealias _OperationInfo = OperationInfo<OperationDetailID, OperationDetails<RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>>
enum DocumentStatus {
    
    case completed, inflight, rejected
}

typealias OperationDetailID = AnywayPaymentUI.OperationDetailID

import Combine

struct Node<Model> {
    
    let model: Model
    private let subscription: AnyCancellable
    
    init(
        model: Model, 
        subscription: AnyCancellable
    ) {
        self.model = model
        self.subscription = subscription
    }
}
