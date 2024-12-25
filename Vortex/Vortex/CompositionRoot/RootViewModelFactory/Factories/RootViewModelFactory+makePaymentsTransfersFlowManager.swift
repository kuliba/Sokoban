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
            httpClient: httpClient,
            log: logger.log,
            loadOperators: composedLoadOperators,
            scheduler: schedulers.main
        )
        
        return composer.compose(categoryType: "housingAndCommunalService", spinner)
    }
}
