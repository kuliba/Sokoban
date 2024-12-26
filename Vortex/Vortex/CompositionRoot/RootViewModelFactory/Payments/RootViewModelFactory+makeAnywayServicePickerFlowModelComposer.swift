//
//  RootViewModelFactory+makeAnywayServicePickerFlowModelComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeAnywayServicePickerFlowModelComposer(
    ) -> AnywayServicePickerFlowModelComposer {
        
        let anywayFlowComposer = makeAnywayFlowComposer()
        let transactionComposer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let pickerNanoServicesComposer = UtilityPaymentNanoServicesComposer(
            model: model,
            httpClient: httpClient,
            log: logger.log,
            loadOperators: composedLoadOperators
        )
        let pickerMicroServicesComposer = AsyncPickerEffectHandlerMicroServicesComposer(
            composer: transactionComposer,
            model: model,
            makeNanoServices: pickerNanoServicesComposer.compose
        )
        
        return .init(
            makeAnywayFlowModel: anywayFlowComposer.compose(transaction:),
            microServices: pickerMicroServicesComposer.compose(),
            model: model,
            scheduler: schedulers.main
        )
    }
}
