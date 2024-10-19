//
//  RootViewModelFactory+makeAnywayServicePickerFlowModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    func makeAnywayServicePickerFlowModelComposer(
        pageSize: Int = 50,
        flag: StubbedFeatureFlag.Option
    ) -> AnywayServicePickerFlowModelComposer {
        
        let transactionModelComposer = AnywayTransactionViewModelComposer(
            flag: flag,
            model: model,
            httpClient: httpClient,
            log: logger.log,
            scheduler: mainScheduler
        )
        let anywayComposer = AnywayFlowComposer(
            makeAnywayTransactionViewModel: transactionModelComposer.compose(transaction:),
            model: model,
            scheduler: mainScheduler
        )
        let loaderComposer = UtilityPaymentOperatorLoaderComposer(
            flag: flag,
            model: model,
            pageSize: pageSize
        )
        let transactionComposer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let loadOperators = loaderComposer.loadOperators(completion:)
        let pickerNanoServicesComposer = UtilityPaymentNanoServicesComposer(
            flag: flag,
            model: model,
            httpClient: httpClient,
            log: logger.log,
            loadOperators: loadOperators
        )
        let pickerMicroServicesComposer = AsyncPickerEffectHandlerMicroServicesComposer(
            composer: transactionComposer, 
            model: model,
            nanoServices: pickerNanoServicesComposer.compose()
        )
        
        return .init(
            makeAnywayFlowModel: anywayComposer.compose(transaction:),
            microServices: pickerMicroServicesComposer.compose(),
            model: model,
            scheduler: mainScheduler
        )
    }
}
