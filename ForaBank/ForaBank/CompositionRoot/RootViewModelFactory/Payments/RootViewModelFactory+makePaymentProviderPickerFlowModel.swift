//
//  RootViewModelFactory+makeSegmentedPaymentProviderPickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeSegmentedPaymentProviderPickerFlowModel(
        pageSize: Int = 50
    ) -> (MultiElementArray<SegmentedOperatorProvider>, QRCode, QRMapping) -> SegmentedPaymentProviderPickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer()
        
        let pickerFlowComposer = SegmentedPaymentProviderPickerFlowModelComposer(
            makeServicePickerFlowModel: servicePickerComposer.compose,
            model: model,
            scheduler: schedulers.main
        )
        
        return pickerFlowComposer.compose
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
