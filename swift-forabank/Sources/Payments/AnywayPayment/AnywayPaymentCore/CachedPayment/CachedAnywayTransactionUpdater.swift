//
//  CachedAnywayTransactionUpdater.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain

public final class CachedAnywayTransactionUpdater<DocumentStatus, Model, OperationDetailID, OperationDetails> {
    
    private let map: Map
    
    public init(
        map: @escaping Map
    ) {
        self.map = map
    }
    
    public typealias Map = (AnywayElement) -> Model
}

public extension CachedAnywayTransactionUpdater {
    
    func update(
        _ cachedTransaction: CachedTransaction,
        with transaction: Transaction
    ) -> CachedTransaction {
        
        return .init(
            payment: .init(
                payment: cachedTransaction.payment.payment.updating(
                    with: transaction.payment.payment,
                    using: map
                ),
                staged: transaction.payment.staged,
                outline: transaction.payment.outline,
                shouldRestart: transaction.payment.shouldRestart
            ),
            isValid: transaction.isValid,
            status: transaction.status
        )
    }
    
    typealias CachedTransaction = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, CachedPaymentContext<Model>>
    typealias Transaction = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, AnywayPaymentContext>
}
