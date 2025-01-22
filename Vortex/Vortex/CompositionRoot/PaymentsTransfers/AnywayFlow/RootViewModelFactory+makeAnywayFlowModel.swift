//
//  RootViewModelFactory+makeAnywayFlowModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeAnywayFlowModel(
        transaction: AnywayTransactionState.Transaction
    ) -> AnywayFlowModel {
        
        let transactionComposer = AnywayTransactionViewModelComposer(
            model: model,
            httpClient: infra.httpClient,
            log: log,
            scheduler: schedulers.main
        )
        
        let composer = AnywayFlowComposer(
            makeAnywayTransactionViewModel: transactionComposer.compose(transaction:),
            model: model,
            scheduler: schedulers.main
        )
        
        return composer.compose(transaction: transaction)
    }
}
