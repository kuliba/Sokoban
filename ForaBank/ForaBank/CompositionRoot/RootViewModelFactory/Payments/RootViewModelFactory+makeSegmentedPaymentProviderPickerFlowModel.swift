//
//  RootViewModelFactory+makeSegmentedPaymentProviderPickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import ForaTools
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeSegmentedPaymentProviderPickerFlowModel(
        multi: MultiElementArray<SegmentedOperatorProvider>,
        qrCode: QRCode,
        qrMapping: QRMapping
    ) -> SegmentedPaymentProviderPickerFlowModel {
        
        let servicePickerComposer = makeAnywayServicePickerFlowModelComposer()
        
        let pickerFlowComposer = SegmentedPaymentProviderPickerFlowModelComposer(
            makeServicePickerFlowModel: servicePickerComposer.compose,
            model: model,
            scheduler: schedulers.main
        )
        
        return pickerFlowComposer.compose(with: multi, qrCode: qrCode, qrMapping: qrMapping)
    }
}
