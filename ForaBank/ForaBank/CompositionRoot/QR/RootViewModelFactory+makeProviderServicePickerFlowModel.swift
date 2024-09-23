//
//  RootViewModelFactory+makeProviderServicePickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

extension RootViewModelFactory {
    
    static func makeProviderServicePickerFlowModel(
        httpClient: HTTPClient,
        log: @escaping Log,
        model: Model,
        pageSize: Int = 50,
        flag: StubbedFeatureFlag.Option,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> (PaymentProviderServicePickerPayload) -> AnywayServicePickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer(
            httpClient: httpClient,
            log: log,
            model: model,
            flag: flag,
            scheduler: scheduler
        )
        
        return {
            
            servicePickerComposer.compose(payload: $0)
        }
    }
}
