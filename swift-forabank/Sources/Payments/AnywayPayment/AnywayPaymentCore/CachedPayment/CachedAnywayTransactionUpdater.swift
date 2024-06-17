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
            context: .init(
                payment: cachedTransaction.context.payment.updating(
                    with: transaction.context.payment,
                    using: map
                ),
                staged: transaction.context.staged,
                outline: transaction.context.outline,
                shouldRestart: transaction.context.shouldRestart
            ),
            isValid: transaction.isValid,
            status: transaction.status
        )
    }
    
    typealias CachedTransaction = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, CachedPaymentContext<Model>>
    typealias Transaction = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, AnywayPaymentContext>
}
