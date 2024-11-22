//
//  RootViewModelFactory+makeAnywayServicePickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation

extension RootViewModelFactory {
    
    func makeAnywayServicePickerFlowModel(
        payload: PaymentProviderServicePickerPayload,
        completion: @escaping (AnywayServicePickerFlowModel) -> Void
    ) {
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer()
        
        completion(servicePickerComposer.compose(payload: payload))
    }
}
