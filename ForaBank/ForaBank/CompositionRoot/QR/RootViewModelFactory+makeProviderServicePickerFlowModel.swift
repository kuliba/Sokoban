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
    
    func makeProviderServicePickerFlowModel(
        pageSize: Int = 50,
        flag: StubbedFeatureFlag.Option,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> (PaymentProviderServicePickerPayload) -> AnywayServicePickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer(
            flag: flag,
            scheduler: scheduler
        )
        
        return {
            
            servicePickerComposer.compose(payload: $0)
        }
    }
}
