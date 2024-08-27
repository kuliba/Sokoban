//
//  RootViewModelFactory+makeAnywayServicePickerFlowModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    static func makeAnywayServicePickerFlowModelComposer(
        httpClient: HTTPClient,
        log: @escaping Log,
        model: Model,
        pageSize: Int = 50,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> AnywayServicePickerFlowModelComposer {
        
        let transactionModelComposer = AnywayTransactionViewModelComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: log,
            scheduler: scheduler
        )
        let anywayComposer = AnywayFlowComposer(
            makeAnywayTransactionViewModel: transactionModelComposer.compose(transaction:),
            model: model,
            scheduler: scheduler
        )
        let loaderComposer = UtilityPaymentOperatorLoaderComposer(
            flag: utilitiesPaymentsFlag.optionOrStub,
            model: model,
            pageSize: pageSize
        )
        let transactionComposer = AnywayTransactionComposer(
            model: model,
            validator: .init()
        )
        let loadOperators = loaderComposer.loadOperators(completion:)
        let pickerNanoServicesComposer = UtilityPaymentNanoServicesComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: log,
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
            scheduler: scheduler
        )
    }
}
