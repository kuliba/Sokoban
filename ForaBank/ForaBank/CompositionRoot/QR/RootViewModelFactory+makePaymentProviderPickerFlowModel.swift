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
    
    func makeSegmentedPaymentProviderPickerFlowModel(
        pageSize: Int = 50,
        flag: StubbedFeatureFlag.Option
    ) -> (MultiElementArray<SegmentedOperatorProvider>, QRCode, QRMapping) -> SegmentedPaymentProviderPickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer(
            flag: flag
        )
        
        let pickerFlowComposer = SegmentedPaymentProviderPickerFlowModelComposer(
            makeServicePickerFlowModel: servicePickerComposer.compose,
            model: model,
            scheduler: mainScheduler
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
