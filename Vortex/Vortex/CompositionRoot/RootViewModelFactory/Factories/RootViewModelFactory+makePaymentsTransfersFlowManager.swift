//
//  RootViewModelFactory+makePaymentsTransfersFlowManager.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.12.2024.
//

extension RootViewModelFactory {
    
    func makePaymentsTransfersFlowManager(
        spinner: RootViewModel.RootActions.Spinner?
    ) -> PaymentsTransfersFlowManager {
        
        let composer = PaymentsTransfersFlowManagerComposer(
            model: model,
            httpClient: infra.httpClient,
            log: log,
            loadOperators: loadCachedOperators,
            scheduler: schedulers.main
        )
        
        return composer.compose(categoryType: "housingAndCommunalService", spinner)
    }
}
