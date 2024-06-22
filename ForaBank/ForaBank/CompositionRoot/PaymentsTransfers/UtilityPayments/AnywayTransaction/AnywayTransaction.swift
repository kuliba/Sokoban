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
    
    public var projectionPublisher: AnyPublisher<FooterProjection, Never> {
        
        $state
            .map(\.projection)
            .map(FooterProjection.init)
            .eraseToAnyPublisher()
    }
    
    public func enableButton(_ isEnabled: Bool) {
        
        self.event(.button(isEnabled ? .enable : .disable))
    }
}

private extension FooterProjection {
    
    init(_ projection: AmountComponent.FooterState.Projection) {
        
        self.init(
            amount: projection.amount, 
            buttonTap: projection.buttonTap.map { .init($0) }
        )
    }
}

private extension FooterProjection.ButtonTap {
    
    init(_ buttonTap: AmountComponent.FooterState.Projection.ButtonTap) {
        
        self.init()
    }
}
