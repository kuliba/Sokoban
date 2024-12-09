//
//  RootViewModelFactory+makeProviderServicePickerFlowModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.08.2024.
//

import CombineSchedulers
import VortexTools
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeProviderServicePickerFlowModel(
        pageSize: Int = 50
    ) -> (PaymentProviderServicePickerPayload) -> AnywayServicePickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer()
        
        return {
            
            servicePickerComposer.compose(payload: $0)
        }
    }
}
