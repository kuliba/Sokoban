//
//  RootViewModelFactory+makeAnywayServicePickerFlowModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeAnywayServicePickerFlowModel(
        payload: PaymentProviderServicePickerPayload
    ) -> AnywayServicePickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer()
        
        return servicePickerComposer.compose(payload: payload)
    }
    
    @inlinable
    func makeAnywayServicePickerFlowModel(
        payload: PaymentProviderServicePickerPayload,
        completion: @escaping (AnywayServicePickerFlowModel) -> Void
    ) {
        completion(makeAnywayServicePickerFlowModel(payload: payload))
    }
}
