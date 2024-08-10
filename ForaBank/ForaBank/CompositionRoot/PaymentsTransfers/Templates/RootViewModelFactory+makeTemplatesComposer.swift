//
//  RootViewModelFactory+makeTemplatesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    static func makeTemplatesComposer(
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> TemplatesListFlowModelComposer {
        
        let anywayTransactionViewModelComposer = AnywayTransactionViewModelComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: log,
            scheduler: scheduler
        )
        let anywayFlowComposer = AnywayFlowComposer(
            composer: anywayTransactionViewModelComposer,
            model: model,
            scheduler: scheduler
        )
        let templatesNanoServicesComposer = TemplatesListFlowEffectHandlerNanoServicesComposer()
        
        return .init(
            composer: anywayFlowComposer,
            model: model,
            nanoServices: templatesNanoServicesComposer.compose(),
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: scheduler
        )
    }
}
