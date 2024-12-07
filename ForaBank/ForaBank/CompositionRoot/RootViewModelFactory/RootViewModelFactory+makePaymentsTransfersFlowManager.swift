//
//  RootViewModelFactory+makePaymentsTransfersFlowManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2024.
//

extension RootViewModelFactory {
    
    func makePaymentsTransfersFlowManager(
        spinner: RootViewModel.RootActions.Spinner?
    ) -> PaymentsTransfersFlowManager {
        
        let operatorLoaderComposer = UtilityPaymentOperatorLoaderComposer(
            model: model,
            pageSize: settings.pageSize
        )
        let composer = PaymentsTransfersFlowManagerComposer(
            model: model,
            httpClient: httpClient,
            log: logger.log,
            loadOperators: operatorLoaderComposer.compose(),
            scheduler: schedulers.main
        )
        
        return composer.compose(spinner)
    }
}
