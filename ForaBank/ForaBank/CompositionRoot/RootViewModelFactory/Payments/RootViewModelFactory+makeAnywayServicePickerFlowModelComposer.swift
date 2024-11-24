//
//  RootViewModelFactory+makeAnywayServicePickerFlowModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeAnywayServicePickerFlowModelComposer(
        pageSize: Int = 50
    ) -> AnywayServicePickerFlowModelComposer {
        
        let anywayFlowComposer = makeAnywayFlowComposer()
        let loaderComposer = UtilityPaymentOperatorLoaderComposer(
            model: model,
            pageSize: pageSize
        )
        let transactionComposer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let loadOperators = loaderComposer.loadOperators(completion:)
        let pickerNanoServicesComposer = UtilityPaymentNanoServicesComposer(
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
            makeAnywayFlowModel: anywayFlowComposer.compose(transaction:),
            microServices: pickerMicroServicesComposer.compose(),
            model: model,
            scheduler: schedulers.main
        )
    }
}

extension UtilityPaymentOperatorLoaderComposer {
    
    func loadOperators(
        completion: @escaping ([UtilityPaymentOperator]) -> Void
    ) {
        let load = compose()
        
        load(.init()) { completion($0); _ = load }
    }
}
