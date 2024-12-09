//
//  RootViewModelFactory+makeAnywayFlowComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeAnywayFlowComposer() -> AnywayFlowComposer {
        
        let anywayTransactionViewModelComposer = AnywayTransactionViewModelComposer(
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: schedulers.main
        )
        
        return AnywayFlowComposer(
            makeAnywayTransactionViewModel: anywayTransactionViewModelComposer.compose(transaction:),
            model: model,
            scheduler: schedulers.main
        )
    }
}
