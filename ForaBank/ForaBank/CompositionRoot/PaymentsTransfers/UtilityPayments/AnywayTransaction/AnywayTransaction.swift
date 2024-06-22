//
//  AnywayTransaction.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import AnywayPaymentUI
import Combine
import PaymentComponents
import RemoteServices
import RxViewModel

typealias AnywayTransactionViewModel = AnywayPaymentUI.AnywayTransactionViewModel<FooterViewModel, AnywayElementModel, DocumentStatus, RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>

typealias AnywayTransactionState = AnywayPaymentUI.CachedModelsTransaction<FooterViewModel, AnywayElementModel, DocumentStatus, RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse>
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

// MARK: - Adapters

extension FooterViewModel: FooterInterface {
    
    public var projectionPublisher: AnyPublisher<Projection, Never> {
        
        $state
            .diff(using: { $1.diff(from: $0) })
            .eraseToAnyPublisher()
    }
    
    public func event(_ event: FooterTransactionEvent) {
        
        switch event {
        case let .isEnabled(isEnabled):
            self.event(.button(isEnabled ? .enable : .disable))

        case let .setStyle(style):
            self.event(.style(style))
        }
    }
}
